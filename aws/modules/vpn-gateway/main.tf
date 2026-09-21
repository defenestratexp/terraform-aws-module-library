# ------------------------------------------------------------------------------
# VPN GATEWAY MODULE
# Creates a Virtual Private Gateway with optional VPN connection
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "vpn-gateway"
  }

  tags = merge(local.default_tags, var.tags)

  # Create customer gateway if requested and IP is provided
  create_customer_gateway = var.create_customer_gateway && var.customer_gateway_ip_address != ""

  # Create VPN connection if customer gateway exists
  create_vpn_connection = var.create_vpn_connection && local.create_customer_gateway
}

# ------------------------------------------------------------------------------
# VPN GATEWAY (VIRTUAL PRIVATE GATEWAY)
# ------------------------------------------------------------------------------

resource "aws_vpn_gateway" "main" {
  vpc_id            = var.vpc_id
  amazon_side_asn   = var.amazon_side_asn
  availability_zone = var.availability_zone

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# VPN GATEWAY ROUTE PROPAGATION
# Automatically propagate VPN routes to specified route tables
# ------------------------------------------------------------------------------

resource "aws_vpn_gateway_route_propagation" "main" {
  for_each = toset(var.route_table_ids)

  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = each.value
}

# ------------------------------------------------------------------------------
# CUSTOMER GATEWAY
# Represents the customer's on-premises VPN device
# ------------------------------------------------------------------------------

resource "aws_customer_gateway" "main" {
  count = local.create_customer_gateway ? 1 : 0

  bgp_asn         = var.customer_gateway_bgp_asn
  ip_address      = var.customer_gateway_ip_address
  type            = var.customer_gateway_type
  certificate_arn = var.customer_gateway_certificate_arn
  device_name     = var.customer_gateway_device_name != "" ? var.customer_gateway_device_name : null

  tags = merge(local.tags, {
    Name = "${var.name}-cgw"
  })
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP FOR TUNNEL LOGGING
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "tunnel_logs" {
  count = var.enable_tunnel_logging && var.create_vpn_connection ? 1 : 0

  name              = var.tunnel_log_group_name != "" ? var.tunnel_log_group_name : "/aws/vpn/${var.name}"
  retention_in_days = var.tunnel_log_retention_days

  tags = merge(local.tags, {
    Name = "${var.name}-tunnel-logs"
  })
}

# ------------------------------------------------------------------------------
# VPN CONNECTION
# Site-to-Site VPN between VPN Gateway and Customer Gateway
# ------------------------------------------------------------------------------

resource "aws_vpn_connection" "main" {
  count = local.create_vpn_connection ? 1 : 0

  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main[0].id
  type                = var.vpn_connection_type

  static_routes_only = var.vpn_connection_static_routes_only

  local_ipv4_network_cidr  = var.vpn_connection_local_ipv4_network_cidr
  remote_ipv4_network_cidr = var.vpn_connection_remote_ipv4_network_cidr


  # Tunnel 1 configuration
  tunnel1_inside_cidr        = var.vpn_connection_tunnel1_inside_cidr
  tunnel1_preshared_key      = var.vpn_connection_tunnel1_preshared_key
  tunnel1_dpd_timeout_action = var.vpn_connection_tunnel1_dpd_timeout_action
  tunnel1_ike_versions       = var.vpn_connection_tunnel1_ike_versions

  # Tunnel 2 configuration
  tunnel2_inside_cidr        = var.vpn_connection_tunnel2_inside_cidr
  tunnel2_preshared_key      = var.vpn_connection_tunnel2_preshared_key
  tunnel2_dpd_timeout_action = var.vpn_connection_tunnel2_dpd_timeout_action
  tunnel2_ike_versions       = var.vpn_connection_tunnel2_ike_versions

  # Tunnel logging
  dynamic "tunnel1_log_options" {
    for_each = var.enable_tunnel_logging ? [1] : []
    content {
      cloudwatch_log_options {
        log_enabled       = true
        log_group_arn     = aws_cloudwatch_log_group.tunnel_logs[0].arn
        log_output_format = "json"
      }
    }
  }

  dynamic "tunnel2_log_options" {
    for_each = var.enable_tunnel_logging ? [1] : []
    content {
      cloudwatch_log_options {
        log_enabled       = true
        log_group_arn     = aws_cloudwatch_log_group.tunnel_logs[0].arn
        log_output_format = "json"
      }
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name}-vpn"
  })
}

# ------------------------------------------------------------------------------
# VPN CONNECTION STATIC ROUTES
# For static routing VPN connections
# ------------------------------------------------------------------------------

resource "aws_vpn_connection_route" "main" {
  for_each = var.vpn_connection_static_routes_only && local.create_vpn_connection ? toset(var.vpn_connection_static_routes) : toset([])

  vpn_connection_id      = aws_vpn_connection.main[0].id
  destination_cidr_block = each.value
}
