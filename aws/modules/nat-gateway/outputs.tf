# ------------------------------------------------------------------------------
# NAT GATEWAY OUTPUTS
# ------------------------------------------------------------------------------

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IP addresses of the NAT Gateways"
  value       = aws_nat_gateway.main[*].public_ip
}

output "eip_ids" {
  description = "List of Elastic IP IDs (empty if reusing existing EIPs)"
  value       = aws_eip.nat[*].id
}

output "eip_allocation_ids" {
  description = "List of Elastic IP allocation IDs"
  value       = var.reuse_existing_eips ? var.existing_eip_allocation_ids : aws_eip.nat[*].allocation_id
}

output "eip_public_ips" {
  description = "List of Elastic IP public addresses"
  value       = var.reuse_existing_eips ? [] : aws_eip.nat[*].public_ip
}

# Convenience outputs
output "nat_gateway_count" {
  description = "Number of NAT Gateways created"
  value       = local.nat_count
}

output "is_single_nat" {
  description = "Whether a single NAT Gateway is used"
  value       = var.single_nat_gateway
}
