# ------------------------------------------------------------------------------
# ECR REPOSITORY MODULE
# Creates an ECR repository with lifecycle policies and access controls
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "ecr-repository"
  }

  tags = merge(local.default_tags, var.tags)

  # Default lifecycle policy
  default_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.untagged_image_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiry_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only last ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Build repository policy for cross-account access
  has_cross_account_access = length(var.allow_pull_accounts) > 0 || length(var.allow_push_accounts) > 0 || var.allow_lambda_pull

  pull_principals = concat(
    [for account in var.allow_pull_accounts : "arn:aws:iam::${account}:root"],
    var.allow_lambda_pull ? ["lambda.amazonaws.com"] : []
  )

  push_principals = [for account in var.allow_push_accounts : "arn:aws:iam::${account}:root"]
}

# ------------------------------------------------------------------------------
# ECR REPOSITORY
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# LIFECYCLE POLICY
# ------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "main" {
  count = var.enable_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.main.name
  policy     = var.custom_lifecycle_policy != null ? var.custom_lifecycle_policy : local.default_lifecycle_policy
}

# ------------------------------------------------------------------------------
# REPOSITORY POLICY
# ------------------------------------------------------------------------------

resource "aws_ecr_repository_policy" "main" {
  count = var.repository_policy != null || local.has_cross_account_access ? 1 : 0

  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy != null ? var.repository_policy : data.aws_iam_policy_document.cross_account[0].json
}

data "aws_iam_policy_document" "cross_account" {
  count = var.repository_policy == null && local.has_cross_account_access ? 1 : 0

  # Pull access
  dynamic "statement" {
    for_each = length(local.pull_principals) > 0 ? [1] : []
    content {
      sid    = "AllowPull"
      effect = "Allow"

      principals {
        type        = var.allow_lambda_pull ? "*" : "AWS"
        identifiers = local.pull_principals
      }

      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
      ]

      dynamic "condition" {
        for_each = var.allow_lambda_pull ? [1] : []
        content {
          test     = "StringLike"
          variable = "aws:sourceArn"
          values   = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"]
        }
      }
    }
  }

  # Push access
  dynamic "statement" {
    for_each = length(local.push_principals) > 0 ? [1] : []
    content {
      sid    = "AllowPush"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = local.push_principals
      }

      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
      ]
    }
  }
}

# ------------------------------------------------------------------------------
# REPLICATION CONFIGURATION
# Note: Replication is configured at the registry level, not repository level
# This creates a replication rule for this specific repository
# ------------------------------------------------------------------------------

resource "aws_ecr_replication_configuration" "main" {
  count = length(var.replication_destinations) > 0 ? 1 : 0

  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.replication_destinations
        content {
          region      = destination.value.region
          registry_id = destination.value.registry_id != null ? destination.value.registry_id : data.aws_caller_identity.current.account_id
        }
      }

      repository_filter {
        filter      = var.name
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}
