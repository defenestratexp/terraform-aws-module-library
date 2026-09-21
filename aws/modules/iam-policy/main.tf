# ------------------------------------------------------------------------------
# IAM POLICY MODULE
# Creates a standalone IAM policy
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "iam-policy"
  }

  tags = merge(local.default_tags, var.tags)

  # Use provided policy or build from statements
  use_custom_policy = var.policy != ""
}

# ------------------------------------------------------------------------------
# POLICY DOCUMENT FROM STATEMENTS
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "main" {
  count = local.use_custom_policy ? 0 : 1

  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

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
# IAM POLICY
# ------------------------------------------------------------------------------

resource "aws_iam_policy" "main" {
  name        = var.name
  description = var.description != "" ? var.description : "IAM policy ${var.name}"
  path        = var.path

  policy = local.use_custom_policy ? var.policy : data.aws_iam_policy_document.main[0].json

  tags = merge(local.tags, {
    Name = var.name
  })
}
