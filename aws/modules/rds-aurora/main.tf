# ------------------------------------------------------------------------------
# RDS AURORA MODULE
# Creates an Aurora cluster with instances
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "rds-aurora"
  }

  tags = merge(local.default_tags, var.tags)

  # Default ports by engine
  port = coalesce(
    var.port,
    var.engine == "aurora-mysql" ? 3306 : 5432
  )

  # Create subnet group if subnet_ids provided
  create_subnet_group = length(var.subnet_ids) > 0 && var.db_subnet_group_name == ""

  # Create cluster parameter group if family provided
  create_cluster_parameter_group = var.cluster_parameter_group_family != "" && var.cluster_parameter_group_name == ""

  # Create db parameter group if family provided
  create_db_parameter_group = var.db_parameter_group_family != "" && var.db_parameter_group_name == ""

  # Final snapshot identifier
  final_snapshot_id = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : "${var.cluster_identifier}-final-snapshot"

  # Determine if using serverless v2
  is_serverless_v2 = var.serverless_v2_scaling != null
}

# ------------------------------------------------------------------------------
# DB SUBNET GROUP
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  count = local.create_subnet_group ? 1 : 0

  name        = var.cluster_identifier
  description = "Subnet group for ${var.cluster_identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.tags, {
    Name = var.cluster_identifier
  })
}

# ------------------------------------------------------------------------------
# CLUSTER PARAMETER GROUP
# ------------------------------------------------------------------------------

resource "aws_rds_cluster_parameter_group" "main" {
  count = local.create_cluster_parameter_group ? 1 : 0

  name        = var.cluster_identifier
  family      = var.cluster_parameter_group_family
  description = "Cluster parameter group for ${var.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.tags, {
    Name = var.cluster_identifier
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# DB PARAMETER GROUP
# ------------------------------------------------------------------------------

resource "aws_db_parameter_group" "main" {
  count = local.create_db_parameter_group ? 1 : 0

  name        = var.cluster_identifier
  family      = var.db_parameter_group_family
  description = "DB parameter group for ${var.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.tags, {
    Name = var.cluster_identifier
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# AURORA CLUSTER
# ------------------------------------------------------------------------------

resource "aws_rds_cluster" "main" {
  cluster_identifier = var.cluster_identifier

  # Engine
  engine         = var.engine
  engine_mode    = local.is_serverless_v2 ? "provisioned" : "provisioned"
  engine_version = var.engine_version

  # Storage
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted && var.kms_key_id != "" ? var.kms_key_id : null
  storage_type      = var.storage_type
  allocated_storage = var.storage_type == "aurora-iopt1" ? var.allocated_storage : null

  # Database
  database_name   = var.database_name != "" ? var.database_name : null
  master_username = var.master_username
  master_password = var.manage_master_user_password ? null : var.master_password
  port            = local.port

  # AWS-managed password
  manage_master_user_password   = var.manage_master_user_password && var.master_password == ""
  master_user_secret_kms_key_id = var.manage_master_user_password && var.master_user_secret_kms_key_id != "" ? var.master_user_secret_kms_key_id : null

  # Networking
  db_subnet_group_name   = local.create_subnet_group ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  availability_zones     = length(var.availability_zones) > 0 ? var.availability_zones : null

  # Serverless v2
  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.is_serverless_v2 ? [var.serverless_v2_scaling] : []
    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }

  # Backup and Maintenance
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  apply_immediately            = var.apply_immediately

  # Monitoring
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Parameters
  db_cluster_parameter_group_name = local.create_cluster_parameter_group ? aws_rds_cluster_parameter_group.main[0].name : (var.cluster_parameter_group_name != "" ? var.cluster_parameter_group_name : null)

  # Deletion
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : local.final_snapshot_id

  # Restore
  snapshot_identifier = var.snapshot_identifier != "" ? var.snapshot_identifier : null

  # IAM Auth
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # Global Database
  global_cluster_identifier      = var.global_cluster_identifier != "" ? var.global_cluster_identifier : null
  enable_global_write_forwarding = var.enable_global_write_forwarding

  tags = merge(local.tags, {
    Name = var.cluster_identifier
  })

  lifecycle {
    ignore_changes = [
      master_password,
      availability_zones
    ]
  }
}

# ------------------------------------------------------------------------------
# AURORA INSTANCES
# ------------------------------------------------------------------------------

resource "aws_rds_cluster_instance" "main" {
  count = var.instance_count

  identifier         = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = local.is_serverless_v2 ? "db.serverless" : var.instance_class

  # Promotion tier (0 = highest priority for writer)
  promotion_tier = count.index

  # Networking
  db_subnet_group_name = local.create_subnet_group ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
  publicly_accessible  = false

  # Maintenance
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Monitoring
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  # Parameters
  db_parameter_group_name = local.create_db_parameter_group ? aws_db_parameter_group.main[0].name : (var.db_parameter_group_name != "" ? var.db_parameter_group_name : null)

  tags = merge(local.tags, {
    Name = "${var.cluster_identifier}-${count.index + 1}"
  })
}
