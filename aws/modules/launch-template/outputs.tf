# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.main.id
}

output "arn" {
  description = "The ARN of the launch template"
  value       = aws_launch_template.main.arn
}

output "name" {
  description = "The name of the launch template"
  value       = aws_launch_template.main.name
}

output "latest_version" {
  description = "The latest version of the launch template"
  value       = aws_launch_template.main.latest_version
}

output "default_version" {
  description = "The default version of the launch template"
  value       = aws_launch_template.main.default_version
}

# Convenience output for ASG reference
output "launch_template" {
  description = "Launch template specification for ASG"
  value = {
    id      = aws_launch_template.main.id
    name    = aws_launch_template.main.name
    version = "$Latest"
  }
}
