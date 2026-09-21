# ------------------------------------------------------------------------------
# REDSHIFT CLUSTER OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The Redshift cluster identifier"
  value       = aws_redshift_cluster.main.id
}

output "arn" {
  description = "The ARN of the Redshift cluster"
  value       = aws_redshift_cluster.main.arn
}

output "cluster_identifier" {
  description = "The Redshift cluster identifier"
  value       = aws_redshift_cluster.main.cluster_identifier
}

output "endpoint" {
  description = "The connection endpoint"
  value       = aws_redshift_cluster.main.endpoint
}

output "dns_name" {
  description = "The DNS name of the cluster"
  value       = aws_redshift_cluster.main.dns_name
}

output "database_name" {
  description = "The name of the default database"
  value       = aws_redshift_cluster.main.database_name
}

output "port" {
  description = "The port number"
  value       = aws_redshift_cluster.main.port
}

output "master_username" {
  description = "The master username"
  value       = aws_redshift_cluster.main.master_username
}

# ------------------------------------------------------------------------------
# SUBNET GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "subnet_group_name" {
  description = "The name of the subnet group"
  value       = local.subnet_group_name
}

output "subnet_group_arn" {
  description = "The ARN of the subnet group"
  value       = var.create_subnet_group ? aws_redshift_subnet_group.main[0].arn : null
}

# ------------------------------------------------------------------------------
# PARAMETER GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "parameter_group_name" {
  description = "The name of the parameter group"
  value       = local.parameter_group_name
}

output "parameter_group_arn" {
  description = "The ARN of the parameter group"
  value       = var.create_parameter_group ? aws_redshift_parameter_group.main[0].arn : null
}
