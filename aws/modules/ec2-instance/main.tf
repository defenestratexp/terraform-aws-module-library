# ------------------------------------------------------------------------------
# EC2 INSTANCE MODULE
# Creates a single EC2 instance with common configurations
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

# Look up latest AMI if not provided
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

  # Standard tags
  default_tags = {
    ManagedBy = "terraform"
    Module    = "ec2-instance"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# EC2 INSTANCE
# ------------------------------------------------------------------------------

resource "aws_instance" "main" {
  ami           = local.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  # Networking
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  source_dest_check           = var.source_dest_check

  # Access
  key_name             = var.key_name != "" ? var.key_name : null
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  # User data
  user_data                   = var.user_data_base64 != "" ? null : (var.user_data != "" ? var.user_data : null)
  user_data_base64            = var.user_data_base64 != "" ? var.user_data_base64 : null
  user_data_replace_on_change = var.user_data_replace_on_change

  # Root volume
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id != "" ? var.root_volume_kms_key_id : null
    delete_on_termination = var.delete_on_termination

    tags = merge(local.tags, {
      Name = "${var.name}-root"
    })
  }

  # Monitoring
  monitoring = var.monitoring

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint = var.metadata_http_endpoint
    http_tokens   = var.metadata_http_tokens
  }

  # Lifecycle
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  tags = merge(local.tags, {
    Name = var.name
  })

  volume_tags = merge(local.tags, {
    Name = "${var.name}-root"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# ------------------------------------------------------------------------------
# ADDITIONAL EBS VOLUMES
# ------------------------------------------------------------------------------

resource "aws_ebs_volume" "additional" {
  count = length(var.additional_ebs_volumes)

  availability_zone = aws_instance.main.availability_zone
  size              = var.additional_ebs_volumes[count.index].volume_size
  type              = var.additional_ebs_volumes[count.index].volume_type
  encrypted         = var.additional_ebs_volumes[count.index].encrypted
  kms_key_id        = var.additional_ebs_volumes[count.index].kms_key_id != "" ? var.additional_ebs_volumes[count.index].kms_key_id : null
  iops              = var.additional_ebs_volumes[count.index].iops
  throughput        = var.additional_ebs_volumes[count.index].throughput

  tags = merge(local.tags, {
    Name = "${var.name}-${replace(var.additional_ebs_volumes[count.index].device_name, "/dev/", "")}"
  })
}

resource "aws_volume_attachment" "additional" {
  count = length(var.additional_ebs_volumes)

  device_name = var.additional_ebs_volumes[count.index].device_name
  volume_id   = aws_ebs_volume.additional[count.index].id
  instance_id = aws_instance.main.id
}
