# ------------------------------------------------------------------------------
# ECS CLUSTER OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# ------------------------------------------------------------------------------
# CAPACITY PROVIDER OUTPUTS
# ------------------------------------------------------------------------------

output "capacity_providers" {
  description = "List of capacity providers associated with the cluster"
  value       = aws_ecs_cluster_capacity_providers.main.capacity_providers
}

output "asg_capacity_provider_names" {
  description = "Map of ASG capacity provider names to their ARNs"
  value       = { for k, v in aws_ecs_capacity_provider.asg : k => v.arn }
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "exec_log_group_name" {
  description = "The name of the CloudWatch log group for ECS Exec"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs_exec[0].name : null
}

output "exec_log_group_arn" {
  description = "The ARN of the CloudWatch log group for ECS Exec"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs_exec[0].arn : null
}
