# ------------------------------------------------------------------------------
# CLOUDWATCH ALARM OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the alarm"
  value       = local.is_metric_alarm ? aws_cloudwatch_metric_alarm.main[0].id : aws_cloudwatch_composite_alarm.main[0].id
}

output "arn" {
  description = "The ARN of the alarm"
  value       = local.is_metric_alarm ? aws_cloudwatch_metric_alarm.main[0].arn : aws_cloudwatch_composite_alarm.main[0].arn
}

output "alarm_name" {
  description = "The name of the alarm"
  value       = var.alarm_name
}

output "alarm_type" {
  description = "The type of alarm (metric or composite)"
  value       = var.alarm_type
}
