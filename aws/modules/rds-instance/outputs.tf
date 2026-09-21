# ------------------------------------------------------------------------------
# RDS INSTANCE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "The database port"
  value       = aws_db_instance.main.port
}

output "username" {
  description = "The master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.main.db_name
}

output "engine" {
  description = "The database engine"
  value       = aws_db_instance.main.engine
}

output "engine_version_actual" {
  description = "The actual engine version"
  value       = aws_db_instance.main.engine_version_actual
}

output "hosted_zone_id" {
  description = "The hosted zone ID for Route53 alias records"
  value       = aws_db_instance.main.hosted_zone_id
}

output "resource_id" {
  description = "The RDS resource ID"
  value       = aws_db_instance.main.resource_id
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = aws_db_instance.main.availability_zone
}

output "multi_az" {
  description = "Whether the instance is multi-AZ"
  value       = aws_db_instance.main.multi_az
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the master password"
  value       = try(aws_db_instance.main.master_user_secret[0].secret_arn, null)
}

output "subnet_group_id" {
  description = "The DB subnet group ID"
  value       = local.create_subnet_group ? aws_db_subnet_group.main[0].id : null
}

output "subnet_group_arn" {
  description = "The DB subnet group ARN"
  value       = local.create_subnet_group ? aws_db_subnet_group.main[0].arn : null
}

output "parameter_group_id" {
  description = "The DB parameter group ID"
  value       = local.create_parameter_group ? aws_db_parameter_group.main[0].id : null
}

output "parameter_group_arn" {
  description = "The DB parameter group ARN"
  value       = local.create_parameter_group ? aws_db_parameter_group.main[0].arn : null
}
