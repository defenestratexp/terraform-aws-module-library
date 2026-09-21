# ------------------------------------------------------------------------------
# TARGET GROUP MODULE
# Creates a target group for ALB or NLB
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "target-group"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine if this is an HTTP-based target group
  is_http = contains(["HTTP", "HTTPS"], var.protocol)

  # Health check protocol defaults to target group protocol
  health_check_protocol = var.health_check_protocol != "" ? var.health_check_protocol : var.protocol
}

# ------------------------------------------------------------------------------
# TARGET GROUP
# ------------------------------------------------------------------------------

resource "aws_lb_target_group" "main" {
  name        = var.name
  vpc_id      = var.vpc_id
  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type

  deregistration_delay = var.deregistration_delay
  slow_start           = local.is_http ? var.slow_start : 0

  # Load balancing algorithm (ALB only)
  load_balancing_algorithm_type = local.is_http ? var.load_balancing_algorithm_type : null

  # Lambda settings
  lambda_multi_value_headers_enabled = var.target_type == "lambda" ? var.lambda_multi_value_headers_enabled : null

  # NLB settings
  proxy_protocol_v2      = !local.is_http ? var.proxy_protocol_v2 : null
  preserve_client_ip     = !local.is_http && var.target_type == "ip" ? var.preserve_client_ip : null
  connection_termination = !local.is_http ? var.connection_termination : null

  # Health check
  health_check {
    enabled             = var.health_check_enabled
    port                = var.health_check_port
    protocol            = local.health_check_protocol
    path                = local.is_http ? var.health_check_path : null
    interval            = var.health_check_interval
    timeout             = local.is_http ? var.health_check_timeout : null
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = local.is_http ? var.health_check_matcher : null
  }

  # Stickiness
  dynamic "stickiness" {
    for_each = var.stickiness_enabled && local.is_http ? [1] : []
    content {
      enabled         = true
      type            = var.stickiness_type
      cookie_duration = var.stickiness_type != "app_cookie" ? var.stickiness_duration : null
      cookie_name     = var.stickiness_type == "app_cookie" ? var.stickiness_cookie_name : null
    }
  }

  # NLB stickiness (source_ip)
  dynamic "stickiness" {
    for_each = var.stickiness_enabled && !local.is_http ? [1] : []
    content {
      enabled = true
      type    = "source_ip"
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })

  lifecycle {
    create_before_destroy = true
  }
}
