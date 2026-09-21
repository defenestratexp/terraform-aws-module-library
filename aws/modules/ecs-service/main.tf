# ------------------------------------------------------------------------------
# ECS SERVICE MODULE
# Creates an ECS service with load balancing, auto scaling, and deployment config
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "ecs-service"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine if using awsvpc network mode
  use_network_configuration = length(var.subnet_ids) > 0
}

# ------------------------------------------------------------------------------
# ECS SERVICE
# ------------------------------------------------------------------------------

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn

  desired_count                     = var.scheduling_strategy == "DAEMON" ? null : var.desired_count
  launch_type                       = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type
  platform_version                  = var.launch_type == "FARGATE" || length(var.capacity_provider_strategy) > 0 ? var.platform_version : null
  scheduling_strategy               = var.scheduling_strategy
  enable_execute_command            = var.enable_execute_command
  force_new_deployment              = var.force_new_deployment
  wait_for_steady_state             = var.wait_for_steady_state
  health_check_grace_period_seconds = length(var.load_balancers) > 0 ? var.health_check_grace_period_seconds : null
  propagate_tags                    = var.propagate_tags

  # Capacity provider strategy
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  # Network configuration (awsvpc)
  dynamic "network_configuration" {
    for_each = local.use_network_configuration ? [1] : []
    content {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = var.assign_public_ip
    }
  }

  # Load balancer configuration
  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Service discovery
  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = service_registries.value.port
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
    }
  }

  # Service Connect
  dynamic "service_connect_configuration" {
    for_each = var.service_connect_configuration != null ? [var.service_connect_configuration] : []
    content {
      enabled   = service_connect_configuration.value.enabled
      namespace = service_connect_configuration.value.namespace

      dynamic "service" {
        for_each = service_connect_configuration.value.service != null ? [service_connect_configuration.value.service] : []
        content {
          port_name      = service.value.port_name
          discovery_name = service.value.discovery_name

          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? [service.value.client_alias] : []
            content {
              port     = client_alias.value.port
              dns_name = client_alias.value.dns_name
            }
          }
        }
      }

      dynamic "log_configuration" {
        for_each = service_connect_configuration.value.log_configuration != null ? [service_connect_configuration.value.log_configuration] : []
        content {
          log_driver = log_configuration.value.log_driver
          options    = log_configuration.value.options
        }
      }
    }
  }

  # Deployment configuration
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker.enable
    rollback = var.deployment_circuit_breaker.rollback
  }

  # Placement strategy (EC2)
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  # Placement constraints
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [
      desired_count, # Allow external scaling
    ]
  }
}

# ------------------------------------------------------------------------------
# AUTO SCALING
# ------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "main" {
  count = var.enable_autoscaling ? 1 : 0

  service_namespace  = "ecs"
  resource_id        = "service/${split("/", var.cluster_id)[1]}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.autoscaling_min_capacity
  max_capacity       = var.autoscaling_max_capacity
}

resource "aws_appautoscaling_policy" "main" {
  for_each = var.enable_autoscaling ? var.autoscaling_policies : {}

  name               = "${var.name}-${each.key}"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  policy_type        = each.value.policy_type

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = each.value.target_tracking != null ? [each.value.target_tracking] : []
    content {
      target_value       = target_tracking_scaling_policy_configuration.value.target_value
      scale_in_cooldown  = target_tracking_scaling_policy_configuration.value.scale_in_cooldown
      scale_out_cooldown = target_tracking_scaling_policy_configuration.value.scale_out_cooldown

      predefined_metric_specification {
        predefined_metric_type = target_tracking_scaling_policy_configuration.value.predefined_metric_type
      }
    }
  }
}
