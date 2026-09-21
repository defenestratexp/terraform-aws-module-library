# ------------------------------------------------------------------------------
# TRANSIT GATEWAY VPC ATTACHMENT MODULE
# Attaches a VPC to a Transit Gateway with route management
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "transit-gateway-attachment"
  }

  tags = merge(local.default_tags, var.tags)

  # Create route combinations for VPC routes to TGW
  vpc_routes = flatten([
    for rt_id in var.vpc_route_table_ids : [
      for cidr in var.destination_cidr_blocks : {
        route_table_id = rt_id
        cidr_block     = cidr
        key            = "${rt_id}-${cidr}"
      }
    ]
  ])
}

# ------------------------------------------------------------------------------
# TRANSIT GATEWAY VPC ATTACHMENT
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  dns_support                                     = var.dns_support
  ipv6_support                                    = var.ipv6_support
  appliance_mode_support                          = var.appliance_mode_support
  transit_gateway_default_route_table_association = var.transit_gateway_route_table_id == "" ? true : false
  transit_gateway_default_route_table_propagation = length(var.transit_gateway_route_table_propagation_ids) == 0 ? true : false

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# TRANSIT GATEWAY ROUTE TABLE ASSOCIATION
# Associate attachment with a specific route table
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  count = var.transit_gateway_route_table_id != "" ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# ------------------------------------------------------------------------------
# TRANSIT GATEWAY ROUTE TABLE PROPAGATIONS
# Propagate routes to specified route tables
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  for_each = toset(var.transit_gateway_route_table_propagation_ids)

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = each.value
}

# ------------------------------------------------------------------------------
# VPC ROUTES TO TRANSIT GATEWAY
# Add routes in VPC route tables pointing to TGW
# ------------------------------------------------------------------------------

resource "aws_route" "to_transit_gateway" {
  for_each = { for route in local.vpc_routes : route.key => route }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}
