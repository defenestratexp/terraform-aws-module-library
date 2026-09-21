# ------------------------------------------------------------------------------
# EFS MODULE
# Creates an Elastic File System with mount targets and access points
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "efs"
  }

  tags = merge(local.default_tags, var.tags)

  # Build secure transport policy if enabled
  secure_transport_policy = var.deny_nonsecure_transport ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyNonSecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  }) : null

  # Use custom policy if provided, otherwise use secure transport policy
  effective_policy = var.file_system_policy != "" ? var.file_system_policy : local.secure_transport_policy
}

# ------------------------------------------------------------------------------
# EFS FILE SYSTEM
# ------------------------------------------------------------------------------

resource "aws_efs_file_system" "main" {
  creation_token = var.name

  encrypted  = var.encrypted
  kms_key_id = var.encrypted && var.kms_key_id != "" ? var.kms_key_id : null

  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy.transition_to_ia != null ? [1] : []
    content {
      transition_to_ia = var.lifecycle_policy.transition_to_ia
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy.transition_to_primary_storage_class != null ? [1] : []
    content {
      transition_to_primary_storage_class = var.lifecycle_policy.transition_to_primary_storage_class
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy.transition_to_archive != null ? [1] : []
    content {
      transition_to_archive = var.lifecycle_policy.transition_to_archive
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# BACKUP POLICY
# ------------------------------------------------------------------------------

resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = var.enable_backup ? "ENABLED" : "DISABLED"
  }
}

# ------------------------------------------------------------------------------
# FILE SYSTEM POLICY
# ------------------------------------------------------------------------------

resource "aws_efs_file_system_policy" "main" {
  count = local.effective_policy != null ? 1 : 0

  file_system_id = aws_efs_file_system.main.id
  policy         = local.effective_policy
}

# ------------------------------------------------------------------------------
# MOUNT TARGETS
# ------------------------------------------------------------------------------

resource "aws_efs_mount_target" "main" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}

# ------------------------------------------------------------------------------
# ACCESS POINTS
# ------------------------------------------------------------------------------

resource "aws_efs_access_point" "main" {
  for_each = var.access_points

  file_system_id = aws_efs_file_system.main.id

  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [each.value.posix_user] : []
    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []
    content {
      path = root_directory.value.path

      dynamic "creation_info" {
        for_each = root_directory.value.creation_info != null ? [root_directory.value.creation_info] : []
        content {
          owner_gid   = creation_info.value.owner_gid
          owner_uid   = creation_info.value.owner_uid
          permissions = creation_info.value.permissions
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name}-${each.key}"
  })
}
