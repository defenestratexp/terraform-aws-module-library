# ------------------------------------------------------------------------------
# VPC FLOW LOGS OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the flow log"
  value       = aws_flow_log.main.id
}

output "arn" {
  description = "The ARN of the flow log"
  value       = aws_flow_log.main.arn
}

output "name" {
  description = "The name of the flow log"
  value       = var.name
}

# ------------------------------------------------------------------------------
# LOG GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = local.is_cloudwatch && var.create_log_group ? aws_cloudwatch_log_group.main[0].arn : null
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = local.is_cloudwatch ? local.log_group_name : null
}

# ------------------------------------------------------------------------------
# IAM ROLE OUTPUTS
# ------------------------------------------------------------------------------

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = local.is_cloudwatch && var.create_iam_role ? aws_iam_role.flow_logs[0].arn : null
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = local.is_cloudwatch && var.create_iam_role ? aws_iam_role.flow_logs[0].name : null
}
