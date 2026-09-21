# ------------------------------------------------------------------------------
# VPC OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "name" {
  description = "The name of the VPC"
  value       = var.name
}

# ------------------------------------------------------------------------------
# INTERNET GATEWAY OUTPUTS
# ------------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# ------------------------------------------------------------------------------
# SUBNET OUTPUTS
# ------------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of public subnet ARNs"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of private subnet ARNs"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of database subnet ARNs"
  value       = aws_subnet.database[*].arn
}

output "database_subnet_cidr_blocks" {
  description = "List of database subnet CIDR blocks"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = try(aws_db_subnet_group.database[0].name, "")
}

# ------------------------------------------------------------------------------
# ROUTE TABLE OUTPUTS
# ------------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs (one per AZ)"
  value       = aws_route_table.private[*].id
}

# ------------------------------------------------------------------------------
# AVAILABILITY ZONE OUTPUTS
# ------------------------------------------------------------------------------

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}

output "az_count" {
  description = "Number of availability zones"
  value       = local.az_count
}

# ------------------------------------------------------------------------------
# CONVENIENCE OUTPUTS FOR MODULE WIRING
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "Alias for id - The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnets" {
  description = "Map of all subnet information by tier"
  value = {
    public = {
      ids         = aws_subnet.public[*].id
      arns        = aws_subnet.public[*].arn
      cidr_blocks = aws_subnet.public[*].cidr_block
    }
    private = {
      ids         = aws_subnet.private[*].id
      arns        = aws_subnet.private[*].arn
      cidr_blocks = aws_subnet.private[*].cidr_block
    }
    database = {
      ids         = aws_subnet.database[*].id
      arns        = aws_subnet.database[*].arn
      cidr_blocks = aws_subnet.database[*].cidr_block
    }
  }
}
