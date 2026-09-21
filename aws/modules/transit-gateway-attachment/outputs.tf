# ------------------------------------------------------------------------------
# TRANSIT GATEWAY ATTACHMENT OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "vpc_owner_id" {
  description = "The AWS account ID of the VPC owner"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.vpc_owner_id
}

output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.transit_gateway_id
}

output "vpc_id" {
  description = "The ID of the attached VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.vpc_id
}

output "subnet_ids" {
  description = "The subnet IDs used for the attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.subnet_ids
}

# ------------------------------------------------------------------------------
# ROUTE TABLE OUTPUTS
# ------------------------------------------------------------------------------

output "route_table_association_id" {
  description = "The ID of the route table association"
  value       = var.transit_gateway_route_table_id != "" ? aws_ec2_transit_gateway_route_table_association.main[0].id : null
}

output "route_table_propagation_ids" {
  description = "Map of route table IDs to propagation resource IDs"
  value       = { for k, v in aws_ec2_transit_gateway_route_table_propagation.main : k => v.id }
}

# ------------------------------------------------------------------------------
# VPC ROUTE OUTPUTS
# ------------------------------------------------------------------------------

output "vpc_route_ids" {
  description = "List of VPC route IDs created"
  value       = [for r in aws_route.to_transit_gateway : r.id]
}
