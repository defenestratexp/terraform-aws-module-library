# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE MODULE
# Creates a launch template for use with Auto Scaling Groups
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_ami" "selected" {
  count = var.ami_id == "" ? 1 : 0

  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_filter_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.selected[0].id

  default_tags = {
    ManagedBy = "terraform"
    Module    = "launch-template"
  }

  tags = merge(local.default_tags, var.tags)

  # Instance tags include name based on launch template name
  all_instance_tags = merge(local.tags, var.instance_tags, {
    Name = var.name
  })

  all_volume_tags = merge(local.tags, var.volume_tags)
}

# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE
# ------------------------------------------------------------------------------

resource "aws_launch_template" "main" {
  name        = var.name
  description = var.description != "" ? var.description : "Launch template for ${var.name}"

  image_id      = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  user_data = var.user_data_base64 != "" ? var.user_data_base64 : (var.user_data != "" ? base64encode(var.user_data) : null)

  update_default_version = var.update_default_version

  # Network interfaces
  dynamic "network_interfaces" {
    for_each = length(var.security_group_ids) > 0 ? [1] : []
    content {
      device_index          = 0
      security_groups       = var.security_group_ids
      delete_on_termination = true
    }
  }

  # IAM instance profile
  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_arn != "" || var.iam_instance_profile_name != "" ? [1] : []
    content {
      arn  = var.iam_instance_profile_arn != "" ? var.iam_instance_profile_arn : null
      name = var.iam_instance_profile_arn == "" && var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null
    }
  }

  # Root volume
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = var.root_volume_encrypted
      kms_key_id            = var.root_volume_kms_key_id != "" ? var.root_volume_kms_key_id : null
      iops                  = var.root_volume_iops
      throughput            = var.root_volume_throughput
      delete_on_termination = var.delete_on_termination
    }
  }

  # Additional block devices
  dynamic "block_device_mappings" {
    for_each = var.additional_block_devices
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        encrypted             = block_device_mappings.value.encrypted
        kms_key_id            = block_device_mappings.value.kms_key_id != "" ? block_device_mappings.value.kms_key_id : null
        iops                  = block_device_mappings.value.iops
        throughput            = block_device_mappings.value.throughput
        delete_on_termination = block_device_mappings.value.delete_on_termination
      }
    }
  }

  # Monitoring
  monitoring {
    enabled = var.monitoring_enabled
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
  }

  # Tags for the launch template itself
  tags = merge(local.tags, {
    Name = var.name
  })

  # Tags for instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags          = local.all_instance_tags
  }

  # Tags for volumes created from this template
  tag_specifications {
    resource_type = "volume"
    tags          = local.all_volume_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}
