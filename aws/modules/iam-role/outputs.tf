# ------------------------------------------------------------------------------
# IAM ROLE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the role"
  value       = aws_iam_role.main.id
}

output "arn" {
  description = "The ARN of the role"
  value       = aws_iam_role.main.arn
}

output "name" {
  description = "The name of the role"
  value       = aws_iam_role.main.name
}

output "unique_id" {
  description = "The unique ID of the role"
  value       = aws_iam_role.main.unique_id
}

output "create_date" {
  description = "The creation date of the role"
  value       = aws_iam_role.main.create_date
}

output "assume_role_policy" {
  description = "The assume role policy document"
  value       = aws_iam_role.main.assume_role_policy
}
