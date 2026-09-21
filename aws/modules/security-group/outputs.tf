# ------------------------------------------------------------------------------
# SECURITY GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the security group"
  value       = aws_security_group.main.id
}

output "arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.main.arn
}

output "name" {
  description = "The name of the security group"
  value       = aws_security_group.main.name
}

output "vpc_id" {
  description = "The VPC ID of the security group"
  value       = aws_security_group.main.vpc_id
}

# Convenience alias
output "security_group_id" {
  description = "Alias for id - The ID of the security group"
  value       = aws_security_group.main.id
}
