# ------------------------------------------------------------------------------
# ECS SERVICE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "cluster" {
  description = "The cluster ARN"
  value       = aws_ecs_service.main.cluster
}

output "desired_count" {
  description = "The desired count of tasks"
  value       = aws_ecs_service.main.desired_count
}

output "task_definition" {
  description = "The task definition ARN"
  value       = aws_ecs_service.main.task_definition
}

# ------------------------------------------------------------------------------
# AUTO SCALING OUTPUTS
# ------------------------------------------------------------------------------

output "autoscaling_target_id" {
  description = "The ID of the auto scaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.main[0].id : null
}

output "autoscaling_policy_arns" {
  description = "Map of auto scaling policy ARNs"
  value       = { for k, v in aws_appautoscaling_policy.main : k => v.arn }
}
