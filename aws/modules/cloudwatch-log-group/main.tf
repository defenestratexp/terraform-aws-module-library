# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP MODULE
# Creates a CloudWatch log group with optional metric and subscription filters
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "cloudwatch-log-group"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "main" {
  name              = var.name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  log_group_class   = var.log_group_class
  skip_destroy      = var.skip_destroy

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# METRIC FILTERS
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "main" {
  for_each = var.metric_filters

  name           = each.key
  log_group_name = aws_cloudwatch_log_group.main.name
  pattern        = each.value.pattern

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = each.value.default_value
    unit          = each.value.unit
    dimensions    = each.value.dimensions
  }
}

# ------------------------------------------------------------------------------
# SUBSCRIPTION FILTERS
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_subscription_filter" "main" {
  for_each = var.subscription_filters

  name            = each.key
  log_group_name  = aws_cloudwatch_log_group.main.name
  destination_arn = each.value.destination_arn
  filter_pattern  = each.value.filter_pattern
  role_arn        = each.value.role_arn
  distribution    = each.value.distribution
}
