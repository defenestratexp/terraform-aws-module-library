# ------------------------------------------------------------------------------
# ELASTICACHE REDIS OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the replication group"
  value       = aws_elasticache_replication_group.main.id
}

output "arn" {
  description = "The ARN of the replication group"
  value       = aws_elasticache_replication_group.main.arn
}

output "replication_group_id" {
  description = "The replication group ID"
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "primary_endpoint_address" {
  description = "The primary endpoint address"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "The reader endpoint address"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "configuration_endpoint_address" {
  description = "The configuration endpoint address (cluster mode only)"
  value       = aws_elasticache_replication_group.main.configuration_endpoint_address
}

output "port" {
  description = "The port number"
  value       = aws_elasticache_replication_group.main.port
}

output "member_clusters" {
  description = "The identities of the cluster members"
  value       = aws_elasticache_replication_group.main.member_clusters
}

output "engine_version_actual" {
  description = "The actual engine version"
  value       = aws_elasticache_replication_group.main.engine_version_actual
}

output "subnet_group_name" {
  description = "The subnet group name"
  value       = local.create_subnet_group ? aws_elasticache_subnet_group.main[0].name : var.subnet_group_name
}

output "parameter_group_name" {
  description = "The parameter group name"
  value       = local.create_parameter_group ? aws_elasticache_parameter_group.main[0].name : var.parameter_group_name
}

output "connection_string" {
  description = "Redis connection string"
  value       = var.cluster_mode_enabled ? "${aws_elasticache_replication_group.main.configuration_endpoint_address}:${aws_elasticache_replication_group.main.port}" : "${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}"
}
