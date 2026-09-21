# ------------------------------------------------------------------------------
# KMS KEY OUTPUTS
# ------------------------------------------------------------------------------

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.main.key_id
}

output "key_arn" {
  description = "The ARN of the key"
  value       = aws_kms_key.main.arn
}

output "alias_arn" {
  description = "The ARN of the alias"
  value       = aws_kms_alias.main.arn
}

output "alias_name" {
  description = "The name of the alias"
  value       = aws_kms_alias.main.name
}

output "target_key_arn" {
  description = "The ARN of the target key (same as key_arn)"
  value       = aws_kms_alias.main.target_key_arn
}
