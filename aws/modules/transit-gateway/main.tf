# ------------------------------------------------------------------------------
# TRANSIT GATEWAY MODULE
# Creates a Transit Gateway hub for connecting VPCs and on-premises networks
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "transit-gateway"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# TRANSIT GATEWAY
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "main" {
  description = var.description != "" ? var.description : "Transit Gateway: ${var.name}"

  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  multicast_support               = var.multicast_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  transit_gateway_cidr_blocks     = length(var.transit_gateway_cidr_blocks) > 0 ? var.transit_gateway_cidr_blocks : null

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# ADDITIONAL ROUTE TABLES
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "main" {
  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(local.tags, each.value.tags, {
    Name = coalesce(each.value.name, "${var.name}-${each.key}")
  })
}

# ------------------------------------------------------------------------------
# RESOURCE ACCESS MANAGER (RAM) SHARE
# For sharing Transit Gateway across accounts
# ------------------------------------------------------------------------------

resource "aws_ram_resource_share" "main" {
  count = var.share_transit_gateway ? 1 : 0

  name                      = var.ram_share_name != "" ? var.ram_share_name : "${var.name}-share"
  allow_external_principals = var.ram_allow_external_principals

  tags = merge(local.tags, {
    Name = var.ram_share_name != "" ? var.ram_share_name : "${var.name}-share"
  })
}

resource "aws_ram_resource_association" "main" {
  count = var.share_transit_gateway ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.main.arn
  resource_share_arn = aws_ram_resource_share.main[0].arn
}

resource "aws_ram_principal_association" "main" {
  for_each = var.share_transit_gateway ? toset(var.ram_principals) : toset([])

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.main[0].arn
}
