# ------------------------------------------------------------------------------
# ECS TASK DEFINITION OUTPUTS
# ------------------------------------------------------------------------------

output "arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "arn_without_revision" {
  description = "The ARN of the task definition without revision"
  value       = replace(aws_ecs_task_definition.main.arn, "/:${aws_ecs_task_definition.main.revision}$/", "")
}

output "family" {
  description = "The family of the task definition"
  value       = aws_ecs_task_definition.main.family
}

output "revision" {
  description = "The revision of the task definition"
  value       = aws_ecs_task_definition.main.revision
}

# ------------------------------------------------------------------------------
# IAM ROLE OUTPUTS
# ------------------------------------------------------------------------------

output "task_role_arn" {
  description = "The ARN of the task IAM role"
  value       = local.task_role_arn
}

output "task_role_name" {
  description = "The name of the task IAM role"
  value       = var.create_task_role ? aws_iam_role.task[0].name : null
}

output "execution_role_arn" {
  description = "The ARN of the execution IAM role"
  value       = local.execution_role_arn
}

output "execution_role_name" {
  description = "The name of the execution IAM role"
  value       = var.create_execution_role ? aws_iam_role.execution[0].name : null
}
