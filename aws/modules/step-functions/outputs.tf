# ------------------------------------------------------------------------------
# STEP FUNCTIONS OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the state machine"
  value       = aws_sfn_state_machine.main.id
}

output "arn" {
  description = "The ARN of the state machine"
  value       = aws_sfn_state_machine.main.arn
}

output "name" {
  description = "The name of the state machine"
  value       = aws_sfn_state_machine.main.name
}

output "status" {
  description = "The status of the state machine"
  value       = aws_sfn_state_machine.main.status
}

output "creation_date" {
  description = "The date the state machine was created"
  value       = aws_sfn_state_machine.main.creation_date
}

output "state_machine_version_arn" {
  description = "The ARN of the state machine version"
  value       = aws_sfn_state_machine.main.state_machine_version_arn
}

# ------------------------------------------------------------------------------
# IAM OUTPUTS
# ------------------------------------------------------------------------------

output "role_arn" {
  description = "The ARN of the state machine IAM role"
  value       = local.role_arn
}

output "role_name" {
  description = "The name of the state machine IAM role"
  value       = var.create_role ? aws_iam_role.sfn[0].name : null
}

# ------------------------------------------------------------------------------
# LOGGING OUTPUTS
# ------------------------------------------------------------------------------

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.sfn[0].name : null
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.sfn[0].arn : null
}
