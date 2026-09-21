# ------------------------------------------------------------------------------
# STEP FUNCTIONS STATE MACHINE MODULE
# Creates a Step Functions state machine with IAM role and logging
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "step-functions"
  }

  tags = merge(local.default_tags, var.tags)

  role_arn = var.role_arn != null ? var.role_arn : (var.create_role ? aws_iam_role.sfn[0].arn : null)

  log_group_arn = var.create_log_group ? aws_cloudwatch_log_group.sfn[0].arn : (var.logging_configuration != null ? var.logging_configuration.log_destination : null)
}

# ------------------------------------------------------------------------------
# IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "sfn" {
  count = var.create_role ? 1 : 0

  name = "${var.name}-sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.name}-sfn"
  })
}

# X-Ray tracing policy
resource "aws_iam_role_policy_attachment" "sfn_xray" {
  count = var.create_role && var.tracing_enabled ? 1 : 0

  role       = aws_iam_role.sfn[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "sfn_logs" {
  count = var.create_role && (var.create_log_group || var.logging_configuration != null) ? 1 : 0

  name = "cloudwatch-logs"
  role = aws_iam_role.sfn[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:CreateLogStream",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_role ? var.role_policies : {}

  role       = aws_iam_role.sfn[0].name
  policy_arn = each.value
}

# Inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = var.create_role ? var.role_inline_policies : {}

  name   = each.key
  role   = aws_iam_role.sfn[0].name
  policy = each.value
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "sfn" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/vendedlogs/states/${var.name}"
  retention_in_days = var.log_group_retention_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(local.tags, {
    Name = "${var.name}-logs"
  })
}

# ------------------------------------------------------------------------------
# STATE MACHINE
# ------------------------------------------------------------------------------

resource "aws_sfn_state_machine" "main" {
  name     = var.name
  role_arn = local.role_arn
  type     = var.type
  publish  = var.publish

  definition = var.definition

  dynamic "logging_configuration" {
    for_each = var.logging_configuration != null || var.create_log_group ? [1] : []
    content {
      level                  = var.logging_configuration != null ? var.logging_configuration.level : "ALL"
      include_execution_data = var.logging_configuration != null ? var.logging_configuration.include_execution_data : true
      log_destination        = "${local.log_group_arn}:*"
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.tracing_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration != null ? [var.encryption_configuration] : []
    content {
      kms_key_id                        = encryption_configuration.value.kms_key_id
      kms_data_key_reuse_period_seconds = encryption_configuration.value.kms_data_key_reuse_period_seconds
      type                              = encryption_configuration.value.type
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })

  depends_on = [
    aws_iam_role_policy.sfn_logs,
    aws_cloudwatch_log_group.sfn,
  ]
}
