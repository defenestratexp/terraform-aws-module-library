# ------------------------------------------------------------------------------
# NAT GATEWAY MODULE
# Creates NAT Gateway(s) with Elastic IPs for private subnet outbound access
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  # Number of NAT Gateways to create
  nat_count = var.single_nat_gateway ? 1 : length(var.public_subnet_ids)

  # Standard tags
  default_tags = {
    ManagedBy = "terraform"
    Module    = "nat-gateway"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# ELASTIC IPS
# ------------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = var.reuse_existing_eips ? 0 : local.nat_count

  domain = "vpc"

  tags = merge(local.tags, {
    Name = local.nat_count > 1 ? "${var.name}-nat-${count.index + 1}" : "${var.name}-nat"
  })

  # EIP may require IGW to exist
  depends_on = []
}

# ------------------------------------------------------------------------------
# NAT GATEWAYS
# ------------------------------------------------------------------------------

resource "aws_nat_gateway" "main" {
  count = local.nat_count

  allocation_id = var.reuse_existing_eips ? var.existing_eip_allocation_ids[count.index] : aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = merge(local.tags, {
    Name = local.nat_count > 1 ? "${var.name}-nat-${count.index + 1}" : "${var.name}-nat"
  })
}

# ------------------------------------------------------------------------------
# ROUTES
# Add NAT Gateway routes to private route tables
# ------------------------------------------------------------------------------

resource "aws_route" "nat" {
  count = length(var.private_route_table_ids)

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"

  # If single NAT, all routes point to the same NAT Gateway
  # If HA NAT, each route table uses its corresponding NAT Gateway
  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index % local.nat_count].id
}
