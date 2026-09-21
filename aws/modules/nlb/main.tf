# ------------------------------------------------------------------------------
# NETWORK LOAD BALANCER MODULE
# Creates a Network Load Balancer with TCP/UDP/TLS listeners
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "nlb"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# NETWORK LOAD BALANCER
# ------------------------------------------------------------------------------

resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "network"
  internal           = var.internal

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  # Subnet mapping with optional Elastic IPs
  dynamic "subnet_mapping" {
    for_each = var.use_elastic_ips ? { for idx, subnet_id in var.subnet_ids : idx => subnet_id } : {}
    content {
      subnet_id     = subnet_mapping.value
      allocation_id = length(var.elastic_ip_allocation_ids) > subnet_mapping.key ? var.elastic_ip_allocation_ids[subnet_mapping.key] : null
    }
  }

  # Simple subnet specification (no EIPs)
  subnets = var.use_elastic_ips ? null : var.subnet_ids

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
# LISTENERS
# ------------------------------------------------------------------------------

resource "aws_lb_listener" "main" {
  count = length(var.listeners)

  load_balancer_arn = aws_lb.main.arn
  port              = var.listeners[count.index].port
  protocol          = var.listeners[count.index].protocol

  # TLS settings
  certificate_arn = var.listeners[count.index].protocol == "TLS" ? var.listeners[count.index].certificate_arn : null
  ssl_policy      = var.listeners[count.index].protocol == "TLS" ? var.listeners[count.index].ssl_policy : null
  alpn_policy     = var.listeners[count.index].alpn_policy

  default_action {
    type             = "forward"
    target_group_arn = var.listeners[count.index].target_group_arn
  }

  tags = merge(local.tags, {
    Name = "${var.name}-${var.listeners[count.index].port}"
  })
}
