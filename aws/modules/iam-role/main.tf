# ------------------------------------------------------------------------------
# IAM ROLE MODULE
# Creates an IAM role with assume role policy and attached policies
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "iam-role"
  }

  tags = merge(local.default_tags, var.tags)

  # Build assume role policy if not provided
  use_custom_policy = var.assume_role_policy != ""

  # Build principals
  service_principals = length(var.trusted_services) > 0 ? [{
    type        = "Service"
    identifiers = var.trusted_services
  }] : []

  account_principals = length(var.trusted_accounts) > 0 ? [{
    type        = "AWS"
    identifiers = [for account in var.trusted_accounts : "arn:aws:iam::${account}:root"]
  }] : []

  role_principals = length(var.trusted_roles) > 0 ? [{
    type        = "AWS"
    identifiers = var.trusted_roles
  }] : []

  federated_principals = [for oidc in var.trusted_oidc_providers : {
    type        = "Federated"
    identifiers = [oidc.provider_arn]
  }]

  all_principals = concat(
    local.service_principals,
    local.account_principals,
    local.role_principals,
    local.federated_principals
  )
}

# ------------------------------------------------------------------------------
# ASSUME ROLE POLICY DOCUMENT
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  count = local.use_custom_policy ? 0 : 1

  dynamic "statement" {
    for_each = local.all_principals
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }

      dynamic "condition" {
        for_each = var.assume_role_condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  # OIDC-specific statements with conditions
  dynamic "statement" {
    for_each = var.trusted_oidc_providers
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [statement.value.provider_arn]
      }

      dynamic "condition" {
        for_each = length(statement.value.client_ids) > 0 ? [1] : []
        content {
          test     = "StringEquals"
          variable = "${replace(statement.value.provider_arn, "/^.*provider\\//", "")}:aud"
          values   = statement.value.client_ids
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "main" {
  name        = var.name
  description = var.description != "" ? var.description : "IAM role ${var.name}"
  path        = var.path

  assume_role_policy = local.use_custom_policy ? var.assume_role_policy : data.aws_iam_policy_document.assume_role[0].json

  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary != "" ? var.permissions_boundary : null
  force_detach_policies = var.force_detach_policies

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# MANAGED POLICY ATTACHMENTS
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.main.name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# INLINE POLICIES
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.main.name
  policy = each.value
}
