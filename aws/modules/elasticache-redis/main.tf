# ------------------------------------------------------------------------------
# ELASTICACHE REDIS MODULE
# Creates an ElastiCache Redis replication group
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "elasticache-redis"
  }

  tags = merge(local.default_tags, var.tags)

  # Create subnet group if subnet_ids provided
  create_subnet_group = length(var.subnet_ids) > 0 && var.subnet_group_name == ""

  # Create parameter group if family provided
  create_parameter_group = var.parameter_group_family != "" && var.parameter_group_name == ""

  # Automatic failover requires at least 2 nodes
  automatic_failover = var.automatic_failover_enabled && (var.num_cache_clusters >= 2 || var.cluster_mode_enabled)
}

# ------------------------------------------------------------------------------
# SUBNET GROUP
# ------------------------------------------------------------------------------

resource "aws_elasticache_subnet_group" "main" {
  count = local.create_subnet_group ? 1 : 0

  name        = var.replication_group_id
  description = "Subnet group for ${var.replication_group_id}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.tags, {
    Name = var.replication_group_id
  })
}

# ------------------------------------------------------------------------------
# PARAMETER GROUP
# ------------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "main" {
  count = local.create_parameter_group ? 1 : 0

  name        = var.replication_group_id
  family      = var.parameter_group_family
  description = "Parameter group for ${var.replication_group_id}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(local.tags, {
    Name = var.replication_group_id
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# REPLICATION GROUP
# ------------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = var.replication_group_id
  description          = "Redis replication group ${var.replication_group_id}"

  # Engine
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = local.create_parameter_group ? aws_elasticache_parameter_group.main[0].name : (var.parameter_group_name != "" ? var.parameter_group_name : null)

  # Cluster configuration
  num_cache_clusters         = var.cluster_mode_enabled ? null : var.num_cache_clusters
  automatic_failover_enabled = local.automatic_failover
  multi_az_enabled           = var.multi_az_enabled && local.automatic_failover

  # Cluster mode (sharding)
  num_node_groups         = var.cluster_mode_enabled ? var.num_node_groups : null
  replicas_per_node_group = var.cluster_mode_enabled ? var.replicas_per_node_group : null

  # Networking
  subnet_group_name  = local.create_subnet_group ? aws_elasticache_subnet_group.main[0].name : (var.subnet_group_name != "" ? var.subnet_group_name : null)
  security_group_ids = var.security_group_ids

  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_enabled ? var.transit_encryption_mode : null
  kms_key_id                 = var.at_rest_encryption_enabled && var.kms_key_id != "" ? var.kms_key_id : null

  # Auth
  auth_token = var.transit_encryption_enabled && var.auth_token != "" ? var.auth_token : null

  # Maintenance
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_retention_limit > 0 ? var.snapshot_window : null
  snapshot_retention_limit   = var.snapshot_retention_limit
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Notifications
  notification_topic_arn = var.notification_topic_arn != "" ? var.notification_topic_arn : null

  # Logging
  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = merge(local.tags, {
    Name = var.replication_group_id
  })

  lifecycle {
    ignore_changes = [
      num_cache_clusters
    ]
  }
}
