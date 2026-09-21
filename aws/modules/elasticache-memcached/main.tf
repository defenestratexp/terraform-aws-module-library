# ------------------------------------------------------------------------------
# ELASTICACHE MEMCACHED MODULE
# Creates an ElastiCache Memcached cluster
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "elasticache-memcached"
  }

  tags = merge(local.default_tags, var.tags)

  # Create subnet group if subnet_ids provided
  create_subnet_group = length(var.subnet_ids) > 0 && var.subnet_group_name == ""

  # Create parameter group if family provided
  create_parameter_group = var.parameter_group_family != "" && var.parameter_group_name == ""

  # Cross-AZ requires multiple nodes
  az_mode = var.num_cache_nodes > 1 ? var.az_mode : "single-az"
}

# ------------------------------------------------------------------------------
# SUBNET GROUP
# ------------------------------------------------------------------------------

resource "aws_elasticache_subnet_group" "main" {
  count = local.create_subnet_group ? 1 : 0

  name        = var.cluster_id
  description = "Subnet group for ${var.cluster_id}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.tags, {
    Name = var.cluster_id
  })
}

# ------------------------------------------------------------------------------
# PARAMETER GROUP
# ------------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "main" {
  count = local.create_parameter_group ? 1 : 0

  name        = var.cluster_id
  family      = var.parameter_group_family
  description = "Parameter group for ${var.cluster_id}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(local.tags, {
    Name = var.cluster_id
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# MEMCACHED CLUSTER
# ------------------------------------------------------------------------------

resource "aws_elasticache_cluster" "main" {
  cluster_id = var.cluster_id

  # Engine
  engine               = "memcached"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = local.create_parameter_group ? aws_elasticache_parameter_group.main[0].name : (var.parameter_group_name != "" ? var.parameter_group_name : null)

  # Cluster configuration
  num_cache_nodes              = var.num_cache_nodes
  az_mode                      = local.az_mode
  preferred_availability_zones = local.az_mode == "cross-az" && length(var.preferred_availability_zones) > 0 ? var.preferred_availability_zones : null

  # Networking
  subnet_group_name  = local.create_subnet_group ? aws_elasticache_subnet_group.main[0].name : (var.subnet_group_name != "" ? var.subnet_group_name : null)
  security_group_ids = var.security_group_ids

  # Maintenance
  maintenance_window = var.maintenance_window
  apply_immediately  = var.apply_immediately

  # Notifications
  notification_topic_arn = var.notification_topic_arn != "" ? var.notification_topic_arn : null

  tags = merge(local.tags, {
    Name = var.cluster_id
  })
}
