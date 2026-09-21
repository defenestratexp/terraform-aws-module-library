# ------------------------------------------------------------------------------
# TRANSIT GATEWAY OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "arn" {
  description = "The ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "owner_id" {
  description = "The AWS account ID of the owner"
  value       = aws_ec2_transit_gateway.main.owner_id
}

output "association_default_route_table_id" {
  description = "The ID of the default association route table"
  value       = aws_ec2_transit_gateway.main.association_default_route_table_id
}

output "propagation_default_route_table_id" {
  description = "The ID of the default propagation route table"
  value       = aws_ec2_transit_gateway.main.propagation_default_route_table_id
}

output "amazon_side_asn" {
  description = "The private ASN for the Amazon side of the Gateway"
  value       = aws_ec2_transit_gateway.main.amazon_side_asn
}

# ------------------------------------------------------------------------------
# ROUTE TABLE OUTPUTS
# ------------------------------------------------------------------------------

output "route_table_ids" {
  description = "Map of route table names to their IDs"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.main : k => v.id }
}

output "route_table_arns" {
  description = "Map of route table names to their ARNs"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.main : k => v.arn }
}

# ------------------------------------------------------------------------------
# RAM SHARE OUTPUTS
# ------------------------------------------------------------------------------

output "ram_resource_share_id" {
  description = "The ID of the RAM resource share"
  value       = var.share_transit_gateway ? aws_ram_resource_share.main[0].id : null
}

output "ram_resource_share_arn" {
  description = "The ARN of the RAM resource share"
  value       = var.share_transit_gateway ? aws_ram_resource_share.main[0].arn : null
}
