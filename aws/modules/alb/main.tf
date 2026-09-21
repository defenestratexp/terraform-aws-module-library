# ------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER MODULE
# Creates an ALB with HTTP and/or HTTPS listeners
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "alb"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# ------------------------------------------------------------------------------

resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.internal

  subnets         = var.subnet_ids
  security_groups = var.security_group_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = var.drop_invalid_header_fields
  preserve_host_header       = var.preserve_host_header

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# HTTP LISTENER
# ------------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  count = var.create_http_listener ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Redirect to HTTPS
  dynamic "default_action" {
    for_each = var.http_listener_action == "redirect" ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # Forward to target group
  dynamic "default_action" {
    for_each = var.http_listener_action == "forward" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = var.http_listener_target_group_arn
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name}-http"
  })
}

# ------------------------------------------------------------------------------
# HTTPS LISTENER
# ------------------------------------------------------------------------------

resource "aws_lb_listener" "https" {
  count = var.create_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.https_listener_ssl_policy
  certificate_arn   = var.https_listener_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.https_listener_target_group_arn
  }

  tags = merge(local.tags, {
    Name = "${var.name}-https"
  })
}

# Additional certificates for HTTPS listener
resource "aws_lb_listener_certificate" "additional" {
  count = var.create_https_listener ? length(var.additional_certificates) : 0

  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = var.additional_certificates[count.index]
}
