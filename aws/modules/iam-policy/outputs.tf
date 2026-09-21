# ------------------------------------------------------------------------------
# IAM POLICY OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The policy ID"
  value       = aws_iam_policy.main.id
}

output "arn" {
  description = "The ARN of the policy"
  value       = aws_iam_policy.main.arn
}

output "name" {
  description = "The name of the policy"
  value       = aws_iam_policy.main.name
}

output "path" {
  description = "The path of the policy"
  value       = aws_iam_policy.main.path
}

output "policy" {
  description = "The policy document"
  value       = aws_iam_policy.main.policy
}

output "policy_id" {
  description = "The policy's ID"
  value       = aws_iam_policy.main.policy_id
}
