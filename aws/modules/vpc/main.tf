# ------------------------------------------------------------------------------
# VPC MODULE
# Creates VPC with public and private subnets across availability zones
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  # Use provided AZs or default to first 2 available
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  az_count = length(local.azs)

  # Calculate subnet CIDRs if not provided
  # Splits VPC CIDR into equal parts: public, private, database (if enabled)
  vpc_cidr_prefix = tonumber(split("/", var.cidr_block)[1])
  subnet_prefix   = local.vpc_cidr_prefix + 4 # /16 becomes /20, giving 16 subnets

  # Auto-calculate subnet CIDRs
  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for i in range(local.az_count) : cidrsubnet(var.cidr_block, local.subnet_prefix - local.vpc_cidr_prefix, i)
  ]

  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    for i in range(local.az_count) : cidrsubnet(var.cidr_block, local.subnet_prefix - local.vpc_cidr_prefix, i + local.az_count)
  ]

  database_subnet_cidrs = length(var.database_subnet_cidrs) > 0 ? var.database_subnet_cidrs : [
    for i in range(local.az_count) : cidrsubnet(var.cidr_block, local.subnet_prefix - local.vpc_cidr_prefix, i + (local.az_count * 2))
  ]

  # Standard tags applied to all resources
  default_tags = {
    ManagedBy = "terraform"
    Module    = "vpc"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# INTERNET GATEWAY
# ------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name}-igw"
  })
}

# ------------------------------------------------------------------------------
# PUBLIC SUBNETS
# ------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.tags, {
    Name = "${var.name}-public-${count.index + 1}"
    Tier = "public"
  })
}

# ------------------------------------------------------------------------------
# PRIVATE SUBNETS
# ------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(local.tags, {
    Name = "${var.name}-private-${count.index + 1}"
    Tier = "private"
  })
}

# ------------------------------------------------------------------------------
# DATABASE SUBNETS (OPTIONAL)
# ------------------------------------------------------------------------------

resource "aws_subnet" "database" {
  count = var.create_database_subnets ? local.az_count : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(local.tags, {
    Name = "${var.name}-database-${count.index + 1}"
    Tier = "database"
  })
}

# Database subnet group for RDS
resource "aws_db_subnet_group" "database" {
  count = var.create_database_subnets ? 1 : 0

  name        = "${var.name}-database"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(local.tags, {
    Name = "${var.name}-database"
  })
}

# ------------------------------------------------------------------------------
# ROUTE TABLES - PUBLIC
# ------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name}-public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# ROUTE TABLES - PRIVATE
# One per AZ to support NAT Gateway per AZ if needed
# ------------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count = local.az_count

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name}-private-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ------------------------------------------------------------------------------
# ROUTE TABLES - DATABASE
# Shares route tables with private subnets
# ------------------------------------------------------------------------------

resource "aws_route_table_association" "database" {
  count = var.create_database_subnets ? local.az_count : 0

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
