# ------------------------------------------------------------------------------
# VPC ENDPOINTS MODULE
# Creates VPC endpoints (Gateway and Interface types)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "vpc-endpoints"
  }

  tags = merge(local.default_tags, var.tags)

  region = data.aws_region.current.name
}

# ------------------------------------------------------------------------------
# GATEWAY ENDPOINTS (S3, DynamoDB)
# ------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.gateway_endpoints

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${local.region}.${each.value.service}"
  vpc_endpoint_type = "Gateway"

  route_table_ids = each.value.route_table_ids
  policy          = each.value.policy

  tags = merge(local.tags, {
    Name = "${each.key}-gateway-endpoint"
  })
}

# ------------------------------------------------------------------------------
# INTERFACE ENDPOINTS
# ------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoints

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${local.region}.${each.value.service}"
  vpc_endpoint_type = "Interface"

  subnet_ids = length(each.value.subnet_ids) > 0 ? each.value.subnet_ids : var.default_subnet_ids

  security_group_ids = length(each.value.security_group_ids) > 0 ? each.value.security_group_ids : var.default_security_group_ids

  private_dns_enabled = each.value.private_dns_enabled
  policy              = each.value.policy

  tags = merge(local.tags, {
    Name = "${each.key}-interface-endpoint"
  })
}
