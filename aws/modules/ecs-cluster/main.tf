# ------------------------------------------------------------------------------
# ECS CLUSTER MODULE
# Creates an ECS cluster with capacity providers and Container Insights
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "ecs-cluster"
  }

  tags = merge(local.default_tags, var.tags)

  # Build capacity provider list
  fargate_providers = concat(
    var.enable_fargate ? ["FARGATE"] : [],
    var.enable_fargate_spot ? ["FARGATE_SPOT"] : []
  )

  # Build default capacity provider strategy
  default_capacity_provider_strategy = concat(
    var.enable_fargate && var.capacity_provider_weights.fargate > 0 ? [
      {
        capacity_provider = "FARGATE"
        weight            = var.capacity_provider_weights.fargate
        base              = var.default_capacity_provider == "FARGATE" ? 1 : 0
      }
    ] : [],
    var.enable_fargate_spot && var.capacity_provider_weights.fargate_spot > 0 ? [
      {
        capacity_provider = "FARGATE_SPOT"
        weight            = var.capacity_provider_weights.fargate_spot
        base              = var.default_capacity_provider == "FARGATE_SPOT" ? 1 : 0
      }
    ] : []
  )
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP (for ECS Exec)
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs_exec" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/ecs/${var.name}/exec"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = merge(local.tags, {
    Name = "${var.name}-ecs-exec"
  })
}

# ------------------------------------------------------------------------------
# ECS CLUSTER
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  dynamic "configuration" {
    for_each = var.execute_command_configuration != null ? [var.execute_command_configuration] : []
    content {
      execute_command_configuration {
        kms_key_id = configuration.value.kms_key_id
        logging    = configuration.value.logging

        dynamic "log_configuration" {
          for_each = configuration.value.log_configuration != null ? [configuration.value.log_configuration] : []
          content {
            cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
            cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name != null ? log_configuration.value.cloud_watch_log_group_name : (var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs_exec[0].name : null)
            s3_bucket_name                 = log_configuration.value.s3_bucket_name
            s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
            s3_key_prefix                  = log_configuration.value.s3_key_prefix
          }
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.service_connect_defaults != null ? [var.service_connect_defaults] : []
    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# CAPACITY PROVIDERS - FARGATE
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = concat(
    local.fargate_providers,
    keys(var.autoscaling_capacity_providers)
  )

  dynamic "default_capacity_provider_strategy" {
    for_each = local.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}

# ------------------------------------------------------------------------------
# CAPACITY PROVIDERS - AUTO SCALING GROUP
# ------------------------------------------------------------------------------

resource "aws_ecs_capacity_provider" "asg" {
  for_each = var.autoscaling_capacity_providers

  name = each.key

  auto_scaling_group_provider {
    auto_scaling_group_arn         = each.value.auto_scaling_group_arn
    managed_termination_protection = each.value.managed_termination_protection

    dynamic "managed_scaling" {
      for_each = each.value.managed_scaling != null ? [each.value.managed_scaling] : []
      content {
        maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
        minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
        status                    = managed_scaling.value.status
        target_capacity           = managed_scaling.value.target_capacity
        instance_warmup_period    = managed_scaling.value.instance_warmup_period
      }
    }
  }

  tags = merge(local.tags, {
    Name = each.key
  })
}
