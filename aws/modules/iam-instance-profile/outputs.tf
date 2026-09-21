# ------------------------------------------------------------------------------
# IAM INSTANCE PROFILE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The instance profile ID"
  value       = aws_iam_instance_profile.main.id
}

output "arn" {
  description = "The ARN of the instance profile"
  value       = aws_iam_instance_profile.main.arn
}

output "name" {
  description = "The name of the instance profile"
  value       = aws_iam_instance_profile.main.name
}

output "unique_id" {
  description = "The unique ID of the instance profile"
  value       = aws_iam_instance_profile.main.unique_id
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].arn : var.role_arn
}

output "role_name" {
  description = "The name of the IAM role"
  value       = local.role_name
}

output "role_id" {
  description = "The ID of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].id : null
}
