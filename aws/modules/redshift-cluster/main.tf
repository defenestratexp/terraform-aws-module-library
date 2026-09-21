# ------------------------------------------------------------------------------
# REDSHIFT CLUSTER MODULE
# Creates a Redshift cluster with optional subnet group and parameter group
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "redshift-cluster"
  }

  tags = merge(local.default_tags, var.tags)

  subnet_group_name    = var.create_subnet_group ? aws_redshift_subnet_group.main[0].name : var.cluster_subnet_group_name
  parameter_group_name = var.create_parameter_group ? aws_redshift_parameter_group.main[0].name : var.cluster_parameter_group_name
}

# ------------------------------------------------------------------------------
# SUBNET GROUP
# ------------------------------------------------------------------------------

resource "aws_redshift_subnet_group" "main" {
  count = var.create_subnet_group ? 1 : 0

  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.tags, {
    Name = "${var.cluster_identifier}-subnet-group"
  })
}

# ------------------------------------------------------------------------------
# PARAMETER GROUP
# ------------------------------------------------------------------------------

resource "aws_redshift_parameter_group" "main" {
  count = var.create_parameter_group ? 1 : 0

  name   = "${var.cluster_identifier}-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value.value
    }
  }

  tags = merge(local.tags, {
    Name = "${var.cluster_identifier}-params"
  })
}

# ------------------------------------------------------------------------------
# REDSHIFT CLUSTER
# ------------------------------------------------------------------------------

resource "aws_redshift_cluster" "main" {
  cluster_identifier = var.cluster_identifier

  # Cluster size
  node_type       = var.node_type
  cluster_type    = var.cluster_type
  number_of_nodes = var.cluster_type == "multi-node" ? var.number_of_nodes : null

  # Database
  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password
  port            = var.port

  # Networking
  vpc_security_group_ids    = var.vpc_security_group_ids
  cluster_subnet_group_name = local.subnet_group_name
  publicly_accessible       = var.publicly_accessible
  elastic_ip                = var.elastic_ip
  enhanced_vpc_routing      = var.enhanced_vpc_routing
  availability_zone         = var.availability_zone

  # Encryption
  encrypted  = var.encrypted
  kms_key_id = var.kms_key_id

  # Parameter group
  cluster_parameter_group_name = local.parameter_group_name

  # Snapshots
  automated_snapshot_retention_period = var.automated_snapshot_retention_period
  snapshot_identifier                 = var.snapshot_identifier
  snapshot_cluster_identifier         = var.snapshot_cluster_identifier
  final_snapshot_identifier           = var.skip_final_snapshot ? null : var.final_snapshot_identifier
  skip_final_snapshot                 = var.skip_final_snapshot

  # Cross-region snapshot copy
  dynamic "snapshot_copy" {
    for_each = var.snapshot_copy != null ? [var.snapshot_copy] : []
    content {
      destination_region = snapshot_copy.value.destination_region
      retention_period   = snapshot_copy.value.retention_period
      grant_name         = snapshot_copy.value.grant_name
    }
  }

  # Maintenance
  preferred_maintenance_window = var.preferred_maintenance_window
  allow_version_upgrade        = var.allow_version_upgrade
  apply_immediately            = var.apply_immediately

  # IAM roles
  iam_roles            = var.iam_roles
  default_iam_role_arn = var.default_iam_role_arn

  # Logging
  dynamic "logging" {
    for_each = var.logging != null ? [var.logging] : []
    content {
      enable               = logging.value.enable
      bucket_name          = logging.value.bucket_name
      s3_key_prefix        = logging.value.s3_key_prefix
      log_destination_type = logging.value.log_destination_type
      log_exports          = logging.value.log_exports
    }
  }

  # Advanced
  aqua_configuration_status            = var.aqua_configuration_status
  availability_zone_relocation_enabled = var.availability_zone_relocation_enabled
  multi_az                             = var.multi_az

  tags = merge(local.tags, {
    Name = var.cluster_identifier
  })
}
