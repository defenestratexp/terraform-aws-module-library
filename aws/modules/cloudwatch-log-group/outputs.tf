# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The name of the log group"
  value       = aws_cloudwatch_log_group.main.id
}

output "arn" {
  description = "The ARN of the log group"
  value       = aws_cloudwatch_log_group.main.arn
}

output "name" {
  description = "The name of the log group"
  value       = aws_cloudwatch_log_group.main.name
}

# ------------------------------------------------------------------------------
# METRIC FILTER OUTPUTS
# ------------------------------------------------------------------------------

output "metric_filter_ids" {
  description = "Map of metric filter names to IDs"
  value       = { for k, v in aws_cloudwatch_log_metric_filter.main : k => v.id }
}

# ------------------------------------------------------------------------------
# SUBSCRIPTION FILTER OUTPUTS
# ------------------------------------------------------------------------------

output "subscription_filter_ids" {
  description = "Map of subscription filter names to IDs"
  value       = { for k, v in aws_cloudwatch_log_subscription_filter.main : k => v.id }
}
