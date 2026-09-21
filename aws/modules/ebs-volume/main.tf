# ------------------------------------------------------------------------------
# EBS VOLUME MODULE
# Creates a standalone EBS volume with optional attachment
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "ebs-volume"
  }

  tags = merge(local.default_tags, var.tags)

  # Default IOPS for volume types that support it
  default_iops = {
    gp3 = 3000
    io1 = 100
    io2 = 100
  }

  # Default throughput for gp3
  default_throughput = 125
}

# ------------------------------------------------------------------------------
# EBS VOLUME
# ------------------------------------------------------------------------------

resource "aws_ebs_volume" "main" {
  availability_zone = var.availability_zone
  size              = var.size
  type              = var.type

  encrypted  = var.encrypted
  kms_key_id = var.encrypted && var.kms_key_id != "" ? var.kms_key_id : null

  iops       = contains(["gp3", "io1", "io2"], var.type) ? coalesce(var.iops, local.default_iops[var.type]) : null
  throughput = var.type == "gp3" ? coalesce(var.throughput, local.default_throughput) : null

  snapshot_id          = var.snapshot_id != "" ? var.snapshot_id : null
  multi_attach_enabled = contains(["io1", "io2"], var.type) ? var.multi_attach_enabled : false

  final_snapshot = var.final_snapshot

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# VOLUME ATTACHMENT
# ------------------------------------------------------------------------------

resource "aws_volume_attachment" "main" {
  count = var.attach_to_instance != "" ? 1 : 0

  device_name = var.device_name
  volume_id   = aws_ebs_volume.main.id
  instance_id = var.attach_to_instance

  force_detach                   = var.force_detach
  stop_instance_before_detaching = var.stop_instance_before_detaching
}
