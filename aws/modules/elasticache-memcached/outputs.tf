# ------------------------------------------------------------------------------
# ELASTICACHE MEMCACHED OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The cluster ID"
  value       = aws_elasticache_cluster.main.id
}

output "arn" {
  description = "The ARN of the cluster"
  value       = aws_elasticache_cluster.main.arn
}

output "cluster_id" {
  description = "The cluster ID"
  value       = aws_elasticache_cluster.main.cluster_id
}

output "configuration_endpoint" {
  description = "The configuration endpoint address"
  value       = aws_elasticache_cluster.main.configuration_endpoint
}

output "cluster_address" {
  description = "The DNS name of the cache cluster (without port)"
  value       = aws_elasticache_cluster.main.cluster_address
}

output "port" {
  description = "The port number"
  value       = aws_elasticache_cluster.main.port
}

output "cache_nodes" {
  description = "List of cache node information"
  value = [
    for node in aws_elasticache_cluster.main.cache_nodes : {
      id                = node.id
      address           = node.address
      port              = node.port
      availability_zone = node.availability_zone
    }
  ]
}

output "engine_version_actual" {
  description = "The actual engine version"
  value       = aws_elasticache_cluster.main.engine_version_actual
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
  description = "Memcached connection string"
  value       = "${aws_elasticache_cluster.main.configuration_endpoint}:${aws_elasticache_cluster.main.port}"
}
