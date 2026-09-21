# ------------------------------------------------------------------------------
# RDS AURORA OUTPUTS
# ------------------------------------------------------------------------------

output "cluster_id" {
  description = "The Aurora cluster ID"
  value       = aws_rds_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the Aurora cluster"
  value       = aws_rds_cluster.main.arn
}

output "cluster_identifier" {
  description = "The cluster identifier"
  value       = aws_rds_cluster.main.cluster_identifier
}

output "cluster_endpoint" {
  description = "The cluster writer endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_port" {
  description = "The database port"
  value       = aws_rds_cluster.main.port
}

output "cluster_database_name" {
  description = "The database name"
  value       = aws_rds_cluster.main.database_name
}

output "cluster_master_username" {
  description = "The master username"
  value       = aws_rds_cluster.main.master_username
  sensitive   = true
}

output "cluster_engine" {
  description = "The database engine"
  value       = aws_rds_cluster.main.engine
}

output "cluster_engine_version_actual" {
  description = "The actual engine version"
  value       = aws_rds_cluster.main.engine_version_actual
}

output "cluster_hosted_zone_id" {
  description = "The hosted zone ID for Route53 alias records"
  value       = aws_rds_cluster.main.hosted_zone_id
}

output "cluster_resource_id" {
  description = "The cluster resource ID"
  value       = aws_rds_cluster.main.cluster_resource_id
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the master password"
  value       = try(aws_rds_cluster.main.master_user_secret[0].secret_arn, null)
}

output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_rds_cluster_instance.main[*].id
}

output "instance_arns" {
  description = "List of instance ARNs"
  value       = aws_rds_cluster_instance.main[*].arn
}

output "instance_identifiers" {
  description = "List of instance identifiers"
  value       = aws_rds_cluster_instance.main[*].identifier
}

output "instance_endpoints" {
  description = "List of instance endpoints"
  value       = aws_rds_cluster_instance.main[*].endpoint
}

output "writer_instance_id" {
  description = "The writer instance ID"
  value       = aws_rds_cluster_instance.main[0].id
}

output "writer_instance_endpoint" {
  description = "The writer instance endpoint"
  value       = aws_rds_cluster_instance.main[0].endpoint
}

output "subnet_group_id" {
  description = "The DB subnet group ID"
  value       = local.create_subnet_group ? aws_db_subnet_group.main[0].id : null
}

output "subnet_group_arn" {
  description = "The DB subnet group ARN"
  value       = local.create_subnet_group ? aws_db_subnet_group.main[0].arn : null
}

output "cluster_parameter_group_id" {
  description = "The cluster parameter group ID"
  value       = local.create_cluster_parameter_group ? aws_rds_cluster_parameter_group.main[0].id : null
}

output "cluster_parameter_group_arn" {
  description = "The cluster parameter group ARN"
  value       = local.create_cluster_parameter_group ? aws_rds_cluster_parameter_group.main[0].arn : null
}

output "db_parameter_group_id" {
  description = "The DB parameter group ID"
  value       = local.create_db_parameter_group ? aws_db_parameter_group.main[0].id : null
}

output "db_parameter_group_arn" {
  description = "The DB parameter group ARN"
  value       = local.create_db_parameter_group ? aws_db_parameter_group.main[0].arn : null
}
