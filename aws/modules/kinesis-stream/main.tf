# ------------------------------------------------------------------------------
# KINESIS STREAM MODULE
# Creates a Kinesis data stream with optional enhanced consumers
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "kinesis-stream"
  }

  tags = merge(local.default_tags, var.tags)

  is_provisioned = var.stream_mode == "PROVISIONED"
}

# ------------------------------------------------------------------------------
# KINESIS STREAM
# ------------------------------------------------------------------------------

resource "aws_kinesis_stream" "main" {
  name = var.name

  # Capacity
  shard_count = local.is_provisioned ? var.shard_count : null

  stream_mode_details {
    stream_mode = var.stream_mode
  }

  # Retention
  retention_period = var.retention_period

  # Encryption
  encryption_type = var.encryption_type
  kms_key_id      = var.encryption_type == "KMS" ? var.kms_key_id : null

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# ENHANCED FAN-OUT CONSUMERS
# ------------------------------------------------------------------------------

resource "aws_kinesis_stream_consumer" "main" {
  for_each = var.consumers

  name       = each.value.name
  stream_arn = aws_kinesis_stream.main.arn
}
