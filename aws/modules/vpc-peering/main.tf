# ------------------------------------------------------------------------------
# VPC PEERING MODULE
# Creates a VPC peering connection with optional route management
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "vpc-peering"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine if this is same-account, same-region (can auto-accept)
  can_auto_accept = var.peer_owner_id == "" && var.peer_region == ""
}

# ------------------------------------------------------------------------------
# VPC PEERING CONNECTION
# ------------------------------------------------------------------------------

resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id

  peer_owner_id = var.peer_owner_id != "" ? var.peer_owner_id : null
  peer_region   = var.peer_region != "" ? var.peer_region : null

  auto_accept = local.can_auto_accept && var.auto_accept

  tags = merge(local.tags, {
    Name = var.name
    Side = "Requester"
  })
}

# ------------------------------------------------------------------------------
# VPC PEERING CONNECTION ACCEPTER
# (Only for same-account peering when auto_accept is false, or to configure options)
# ------------------------------------------------------------------------------

resource "aws_vpc_peering_connection_accepter" "main" {
  count = local.can_auto_accept ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept               = var.auto_accept

  tags = merge(local.tags, {
    Name = var.name
    Side = "Accepter"
  })
}

# ------------------------------------------------------------------------------
# PEERING CONNECTION OPTIONS - REQUESTER
# ------------------------------------------------------------------------------

resource "aws_vpc_peering_connection_options" "requester" {
  count = local.can_auto_accept && var.auto_accept ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# ------------------------------------------------------------------------------
# PEERING CONNECTION OPTIONS - ACCEPTER
# ------------------------------------------------------------------------------

resource "aws_vpc_peering_connection_options" "accepter" {
  count = local.can_auto_accept && var.auto_accept ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  accepter {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# ------------------------------------------------------------------------------
# ROUTES - REQUESTER TO ACCEPTER
# ------------------------------------------------------------------------------

resource "aws_route" "requester_to_accepter" {
  for_each = var.accepter_cidr_block != "" ? toset(var.requester_route_table_ids) : toset([])

  route_table_id            = each.value
  destination_cidr_block    = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# ------------------------------------------------------------------------------
# ROUTES - ACCEPTER TO REQUESTER
# ------------------------------------------------------------------------------

resource "aws_route" "accepter_to_requester" {
  for_each = var.requester_cidr_block != "" ? toset(var.accepter_route_table_ids) : toset([])

  route_table_id            = each.value
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  depends_on = [aws_vpc_peering_connection_accepter.main]
}
