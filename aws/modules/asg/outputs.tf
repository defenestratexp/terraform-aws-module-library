# ------------------------------------------------------------------------------
# AUTO SCALING GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.min_size
}

output "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.max_size
}

output "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.desired_capacity
}

output "availability_zones" {
  description = "Availability zones of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.availability_zones
}

output "vpc_zone_identifier" {
  description = "Subnet IDs used by the Auto Scaling Group"
  value       = aws_autoscaling_group.main.vpc_zone_identifier
}

output "target_group_arns" {
  description = "Target group ARNs attached to the Auto Scaling Group"
  value       = aws_autoscaling_group.main.target_group_arns
}

output "scaling_policy_arn" {
  description = "ARN of the CPU target tracking scaling policy (if enabled)"
  value       = var.enable_target_tracking_scaling ? aws_autoscaling_policy.target_tracking_cpu[0].arn : null
}
