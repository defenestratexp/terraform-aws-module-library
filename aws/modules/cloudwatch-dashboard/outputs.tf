# ------------------------------------------------------------------------------
# CLOUDWATCH DASHBOARD OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The name of the dashboard"
  value       = aws_cloudwatch_dashboard.main.id
}

output "arn" {
  description = "The ARN of the dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "name" {
  description = "The name of the dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
