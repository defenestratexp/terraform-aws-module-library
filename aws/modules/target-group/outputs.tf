# ------------------------------------------------------------------------------
# TARGET GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the target group"
  value       = aws_lb_target_group.main.id
}

output "arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "arn_suffix" {
  description = "The ARN suffix of the target group (for CloudWatch metrics)"
  value       = aws_lb_target_group.main.arn_suffix
}

output "name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.main.name
}

output "port" {
  description = "The port of the target group"
  value       = aws_lb_target_group.main.port
}

output "protocol" {
  description = "The protocol of the target group"
  value       = aws_lb_target_group.main.protocol
}

output "target_type" {
  description = "The target type of the target group"
  value       = aws_lb_target_group.main.target_type
}

# Convenience alias
output "target_group_arn" {
  description = "Alias for arn - The ARN of the target group"
  value       = aws_lb_target_group.main.arn
}
