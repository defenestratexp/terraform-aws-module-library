# ------------------------------------------------------------------------------
# CLOUDWATCH ALARM MODULE
# Creates CloudWatch metric or composite alarms
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "cloudwatch-alarm"
  }

  tags = merge(local.default_tags, var.tags)

  is_metric_alarm    = var.alarm_type == "metric"
  is_composite_alarm = var.alarm_type == "composite"
  use_metric_query   = length(var.metric_queries) > 0
}

# ------------------------------------------------------------------------------
# METRIC ALARM
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "main" {
  count = local.is_metric_alarm ? 1 : 0

  alarm_name        = var.alarm_name
  alarm_description = var.alarm_description

  # Metric settings (when not using metric_query)
  metric_name = local.use_metric_query ? null : var.metric_name
  namespace   = local.use_metric_query ? null : var.namespace
  statistic   = local.use_metric_query ? null : var.statistic
  period      = local.use_metric_query ? null : var.period
  dimensions  = local.use_metric_query ? null : (length(var.dimensions) > 0 ? var.dimensions : null)
  unit        = local.use_metric_query ? null : var.unit

  extended_statistic = var.extended_statistic

  # Metric queries (for math expressions or multiple metrics)
  dynamic "metric_query" {
    for_each = var.metric_queries
    content {
      id          = metric_query.value.id
      expression  = metric_query.value.expression
      label       = metric_query.value.label
      return_data = metric_query.value.return_data
      period      = metric_query.value.period

      dynamic "metric" {
        for_each = metric_query.value.metric != null ? [metric_query.value.metric] : []
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          dimensions  = metric.value.dimensions
          unit        = metric.value.unit
        }
      }
    }
  }

  # Threshold settings
  comparison_operator = var.comparison_operator
  threshold           = var.threshold
  threshold_metric_id = var.threshold_metric_id

  # Evaluation settings
  evaluation_periods                    = var.evaluation_periods
  datapoints_to_alarm                   = var.datapoints_to_alarm
  treat_missing_data                    = var.treat_missing_data
  evaluate_low_sample_count_percentiles = var.evaluate_low_sample_count_percentiles

  # Actions
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = merge(local.tags, {
    Name = var.alarm_name
  })
}

# ------------------------------------------------------------------------------
# COMPOSITE ALARM
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_composite_alarm" "main" {
  count = local.is_composite_alarm ? 1 : 0

  alarm_name        = var.alarm_name
  alarm_description = var.alarm_description
  alarm_rule        = var.alarm_rule

  # Actions suppressor
  dynamic "actions_suppressor" {
    for_each = var.actions_suppressor != null ? [1] : []
    content {
      alarm            = var.actions_suppressor
      wait_period      = var.actions_suppressor_wait_period
      extension_period = var.actions_suppressor_extension_period
    }
  }

  # Actions
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = merge(local.tags, {
    Name = var.alarm_name
  })
}
