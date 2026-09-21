# ------------------------------------------------------------------------------
# IAM USER OUTPUTS
# ------------------------------------------------------------------------------

output "name" {
  description = "The user's name"
  value       = aws_iam_user.main.name
}

output "arn" {
  description = "The ARN of the user"
  value       = aws_iam_user.main.arn
}

output "unique_id" {
  description = "The unique ID of the user"
  value       = aws_iam_user.main.unique_id
}

output "access_key_id" {
  description = "The access key ID"
  value       = var.create_access_key ? aws_iam_access_key.main[0].id : null
}

output "secret_access_key" {
  description = "The secret access key (only available if pgp_key is not set)"
  value       = var.create_access_key && var.pgp_key == "" ? aws_iam_access_key.main[0].secret : null
  sensitive   = true
}

output "encrypted_secret" {
  description = "The encrypted secret access key (only available if pgp_key is set)"
  value       = var.create_access_key && var.pgp_key != "" ? aws_iam_access_key.main[0].encrypted_secret : null
}

output "encrypted_password" {
  description = "The encrypted console password (only available if pgp_key is set)"
  value       = var.create_login_profile && var.pgp_key != "" ? aws_iam_user_login_profile.main[0].encrypted_password : null
}

output "key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the secret"
  value       = var.create_access_key && var.pgp_key != "" ? aws_iam_access_key.main[0].key_fingerprint : null
}
