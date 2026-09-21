# ------------------------------------------------------------------------------
# SECRETS MANAGER OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the secret"
  value       = aws_secretsmanager_secret.main.id
}

output "arn" {
  description = "The ARN of the secret"
  value       = aws_secretsmanager_secret.main.arn
}

output "name" {
  description = "The name of the secret"
  value       = aws_secretsmanager_secret.main.name
}

output "version_id" {
  description = "The version ID of the secret"
  value       = try(local.secret_version.version_id, null)
}

output "version_stages" {
  description = "The version stages of the secret"
  value       = try(local.secret_version.version_stages, null)
}

output "replica_status" {
  description = "Status of secret replicas"
  value = {
    for replica in aws_secretsmanager_secret.main.replica : replica.region => {
      status             = replica.status
      status_message     = replica.status_message
      kms_key_id         = replica.kms_key_id
      last_accessed_date = replica.last_accessed_date
    }
  }
}
