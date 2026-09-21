# ------------------------------------------------------------------------------
# KMS KEY MODULE
# Creates a KMS customer managed key with configurable policy
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "kms-key"
  }

  tags = merge(local.default_tags, var.tags)

  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  # Use custom policy or build one
  use_custom_policy = var.policy != ""

  # Only enable rotation for symmetric keys
  enable_rotation = var.enable_key_rotation && var.customer_master_key_spec == "SYMMETRIC_DEFAULT"
}

# ------------------------------------------------------------------------------
# KEY POLICY DOCUMENT
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "key_policy" {
  count = local.use_custom_policy ? 0 : 1

  # Default policy - allow root account full access
  dynamic "statement" {
    for_each = var.enable_default_policy ? [1] : []
    content {
      sid    = "EnableRootAccountAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
      }

      actions   = ["kms:*"]
      resources = ["*"]
    }
  }

  # Key administrators
  dynamic "statement" {
    for_each = length(var.key_administrators) > 0 ? [1] : []
    content {
      sid    = "KeyAdministrators"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_administrators
      }

      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ]
      resources = ["*"]
    }
  }

  # Key users
  dynamic "statement" {
    for_each = length(var.key_users) > 0 ? [1] : []
    content {
      sid    = "KeyUsers"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_users
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }

  # Allow key users to create grants for AWS services
  dynamic "statement" {
    for_each = length(var.key_service_users) > 0 ? [1] : []
    content {
      sid    = "KeyServiceUsers"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_service_users
      }

      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]
      resources = ["*"]

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }

  # Allow specific services to use the key via grants
  dynamic "statement" {
    for_each = length(var.key_grants) > 0 ? [1] : []
    content {
      sid    = "AllowServiceGrants"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = var.key_grants
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:CreateGrant"
      ]
      resources = ["*"]
    }
  }
}

# ------------------------------------------------------------------------------
# KMS KEY
# ------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description = var.description != "" ? var.description : "KMS key ${var.alias}"

  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  multi_region             = var.multi_region

  policy = local.use_custom_policy ? var.policy : data.aws_iam_policy_document.key_policy[0].json

  enable_key_rotation     = local.enable_rotation
  rotation_period_in_days = local.enable_rotation ? var.rotation_period_in_days : null

  deletion_window_in_days = var.deletion_window_in_days
  is_enabled              = var.is_enabled

  tags = merge(local.tags, {
    Name = var.alias
  })
}

# ------------------------------------------------------------------------------
# KMS ALIAS
# ------------------------------------------------------------------------------

resource "aws_kms_alias" "main" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.main.key_id
}
