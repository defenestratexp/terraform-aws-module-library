# ------------------------------------------------------------------------------
# AUTO SCALING GROUP MODULE
# Creates an ASG with optional scaling policies and instance refresh
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "asg"
  }

  tags = merge(local.default_tags, var.tags)

  # Combine propagate tags
  all_propagate_tags = merge(local.tags, var.propagate_tags_at_launch, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP
# ------------------------------------------------------------------------------

resource "aws_autoscaling_group" "main" {
  name                = var.name
  vpc_zone_identifier = var.subnet_ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity != null ? var.desired_capacity : var.min_size

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  # Health checks
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown

  # Lifecycle
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes

  # Load balancer attachment
  target_group_arns = var.target_group_arns

  # Instance refresh for rolling updates
  dynamic "instance_refresh" {
    for_each = var.instance_refresh_enabled ? [1] : []
    content {
      strategy = var.instance_refresh_strategy

      preferences {
        min_healthy_percentage = var.instance_refresh_min_healthy_percentage
        instance_warmup        = var.instance_refresh_instance_warmup
      }
    }
  }

  # Tags propagated to instances
  dynamic "tag" {
    for_each = local.all_propagate_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# ------------------------------------------------------------------------------
# TARGET TRACKING SCALING POLICY
# ------------------------------------------------------------------------------

resource "aws_autoscaling_policy" "target_tracking_cpu" {
  count = var.enable_target_tracking_scaling ? 1 : 0

  name                   = "${var.name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = var.target_tracking_cpu_target
    disable_scale_in = var.target_tracking_disable_scale_in
  }
}
