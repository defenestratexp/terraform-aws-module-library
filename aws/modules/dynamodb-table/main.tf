# ------------------------------------------------------------------------------
# DYNAMODB TABLE MODULE
# Creates a DynamoDB table with optional GSIs, LSIs, streams, and autoscaling
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "dynamodb-table"
  }

  tags = merge(local.default_tags, var.tags)

  # Build attribute list from hash_key, range_key, GSIs, LSIs, and explicit attributes
  hash_key_attr = [{
    name = var.hash_key
    type = "S"
  }]

  range_key_attr = var.range_key != "" ? [{
    name = var.range_key
    type = "S"
  }] : []

  gsi_attrs = flatten([
    for gsi in var.global_secondary_indexes : concat(
      [{ name = gsi.hash_key, type = "S" }],
      gsi.range_key != null ? [{ name = gsi.range_key, type = "S" }] : []
    )
  ])

  lsi_attrs = [
    for lsi in var.local_secondary_indexes : {
      name = lsi.range_key
      type = "S"
    }
  ]

  # Combine all attributes and deduplicate
  all_attrs = concat(local.hash_key_attr, local.range_key_attr, local.gsi_attrs, local.lsi_attrs, var.attributes)

  unique_attrs = { for attr in local.all_attrs : attr.name => attr }

  # Autoscaling configuration
  enable_read_autoscaling  = var.autoscaling_enabled && var.billing_mode == "PROVISIONED"
  enable_write_autoscaling = var.autoscaling_enabled && var.billing_mode == "PROVISIONED"
}

# ------------------------------------------------------------------------------
# DYNAMODB TABLE
# ------------------------------------------------------------------------------

resource "aws_dynamodb_table" "main" {
  name         = var.name
  billing_mode = var.billing_mode

  # Capacity (only for PROVISIONED)
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Keys
  hash_key  = var.hash_key
  range_key = var.range_key != "" ? var.range_key : null

  # Attributes
  dynamic "attribute" {
    for_each = local.unique_attrs
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  # TTL
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  # Streams
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  # Encryption
  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.server_side_encryption_enabled && var.server_side_encryption_kms_key_arn != "" ? var.server_side_encryption_kms_key_arn : null
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Global table replicas
  dynamic "replica" {
    for_each = toset(var.replica_regions)
    content {
      region_name = replica.value
    }
  }

  # Table class
  table_class = var.table_class

  # Deletion protection
  deletion_protection_enabled = var.deletion_protection_enabled

  tags = merge(local.tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }
}

# ------------------------------------------------------------------------------
# AUTOSCALING - READ CAPACITY
# ------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "read" {
  count = local.enable_read_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_read.max_capacity
  min_capacity       = var.autoscaling_read.min_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  count = local.enable_read_autoscaling ? 1 : 0

  name               = "${var.name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = var.autoscaling_read.target_value
    scale_in_cooldown  = var.autoscaling_read.scale_in_cooldown
    scale_out_cooldown = var.autoscaling_read.scale_out_cooldown
  }
}

# ------------------------------------------------------------------------------
# AUTOSCALING - WRITE CAPACITY
# ------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "write" {
  count = local.enable_write_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_write.max_capacity
  min_capacity       = var.autoscaling_write.min_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  count = local.enable_write_autoscaling ? 1 : 0

  name               = "${var.name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = var.autoscaling_write.target_value
    scale_in_cooldown  = var.autoscaling_write.scale_in_cooldown
    scale_out_cooldown = var.autoscaling_write.scale_out_cooldown
  }
}
