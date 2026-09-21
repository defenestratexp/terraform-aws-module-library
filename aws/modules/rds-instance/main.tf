# ------------------------------------------------------------------------------
# RDS INSTANCE MODULE
# Creates a single RDS database instance with optional features
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "rds-instance"
  }

  tags = merge(local.default_tags, var.tags)

  # Default ports by engine
  default_ports = {
    mysql      = 3306
    postgres   = 5432
    mariadb    = 3306
    oracle-ee  = 1521
    oracle-se2 = 1521
    oracle-se1 = 1521
    oracle-se  = 1521
  }

  # Determine port - check exact match first, then prefix
  port = coalesce(
    var.port,
    lookup(local.default_ports, var.engine, null),
    startswith(var.engine, "oracle-") ? 1521 : null,
    startswith(var.engine, "sqlserver-") ? 1433 : null,
    3306
  )

  # Create subnet group if subnet_ids provided and no existing group name
  create_subnet_group = length(var.subnet_ids) > 0 && var.db_subnet_group_name == ""

  # Create parameter group if family provided and no existing group name
  create_parameter_group = var.parameter_group_family != "" && var.parameter_group_name == ""

  # Final snapshot identifier
  final_snapshot_id = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : "${var.identifier}-final-snapshot"
}

# ------------------------------------------------------------------------------
# DB SUBNET GROUP
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  count = local.create_subnet_group ? 1 : 0

  name        = var.identifier
  description = "Subnet group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.tags, {
    Name = var.identifier
  })
}

# ------------------------------------------------------------------------------
# DB PARAMETER GROUP
# ------------------------------------------------------------------------------

resource "aws_db_parameter_group" "main" {
  count = local.create_parameter_group ? 1 : 0

  name        = var.identifier
  family      = var.parameter_group_family
  description = "Parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.tags, {
    Name = var.identifier
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# RDS INSTANCE
# ------------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier = var.identifier

  # Engine
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  iops                  = var.iops
  storage_throughput    = var.storage_throughput
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.storage_encrypted && var.kms_key_id != "" ? var.kms_key_id : null

  # Database
  db_name  = var.db_name != "" ? var.db_name : null
  username = var.username
  password = var.manage_master_user_password ? null : var.password
  port     = local.port

  # AWS-managed password
  manage_master_user_password   = var.manage_master_user_password && var.password == ""
  master_user_secret_kms_key_id = var.manage_master_user_password && var.master_user_secret_kms_key_id != "" ? var.master_user_secret_kms_key_id : null

  # Networking
  db_subnet_group_name   = local.create_subnet_group ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible
  availability_zone      = var.multi_az ? null : (var.availability_zone != "" ? var.availability_zone : null)

  # High Availability
  multi_az = var.multi_az

  # Backup and Maintenance
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  # Monitoring
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  # Parameters and Options
  parameter_group_name = local.create_parameter_group ? aws_db_parameter_group.main[0].name : (var.parameter_group_name != "" ? var.parameter_group_name : null)
  option_group_name    = var.option_group_name != "" ? var.option_group_name : null

  # Deletion
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : local.final_snapshot_id
  delete_automated_backups  = var.delete_automated_backups

  # Restore
  snapshot_identifier = var.snapshot_identifier != "" ? var.snapshot_identifier : null

  # IAM Auth
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  tags = merge(local.tags, {
    Name = var.identifier
  })

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}
