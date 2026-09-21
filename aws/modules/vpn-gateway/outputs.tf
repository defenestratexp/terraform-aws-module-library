# ------------------------------------------------------------------------------
# VPN GATEWAY OUTPUTS
# ------------------------------------------------------------------------------

output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = aws_vpn_gateway.main.id
}

output "vpn_gateway_arn" {
  description = "The ARN of the VPN Gateway"
  value       = aws_vpn_gateway.main.arn
}

output "vpn_gateway_amazon_side_asn" {
  description = "The ASN on the Amazon side of the gateway"
  value       = aws_vpn_gateway.main.amazon_side_asn
}

# ------------------------------------------------------------------------------
# CUSTOMER GATEWAY OUTPUTS
# ------------------------------------------------------------------------------

output "customer_gateway_id" {
  description = "The ID of the Customer Gateway"
  value       = local.create_customer_gateway ? aws_customer_gateway.main[0].id : null
}

output "customer_gateway_arn" {
  description = "The ARN of the Customer Gateway"
  value       = local.create_customer_gateway ? aws_customer_gateway.main[0].arn : null
}

output "customer_gateway_bgp_asn" {
  description = "The BGP ASN of the Customer Gateway"
  value       = local.create_customer_gateway ? aws_customer_gateway.main[0].bgp_asn : null
}

# ------------------------------------------------------------------------------
# VPN CONNECTION OUTPUTS
# ------------------------------------------------------------------------------

output "vpn_connection_id" {
  description = "The ID of the VPN connection"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].id : null
}

output "vpn_connection_arn" {
  description = "The ARN of the VPN connection"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].arn : null
}

output "vpn_connection_tunnel1_address" {
  description = "Public IP address of tunnel 1"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel1_address : null
}

output "vpn_connection_tunnel2_address" {
  description = "Public IP address of tunnel 2"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel2_address : null
}

output "vpn_connection_tunnel1_bgp_asn" {
  description = "BGP ASN of tunnel 1"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel1_bgp_asn : null
}

output "vpn_connection_tunnel2_bgp_asn" {
  description = "BGP ASN of tunnel 2"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel2_bgp_asn : null
}

output "vpn_connection_tunnel1_cgw_inside_address" {
  description = "Customer gateway inside address for tunnel 1"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel1_cgw_inside_address : null
}

output "vpn_connection_tunnel2_cgw_inside_address" {
  description = "Customer gateway inside address for tunnel 2"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel2_cgw_inside_address : null
}

output "vpn_connection_tunnel1_vgw_inside_address" {
  description = "VPN gateway inside address for tunnel 1"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel1_vgw_inside_address : null
}

output "vpn_connection_tunnel2_vgw_inside_address" {
  description = "VPN gateway inside address for tunnel 2"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].tunnel2_vgw_inside_address : null
}

output "vpn_connection_customer_gateway_configuration" {
  description = "XML configuration for the customer gateway device"
  value       = local.create_vpn_connection ? aws_vpn_connection.main[0].customer_gateway_configuration : null
  sensitive   = true
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "tunnel_log_group_name" {
  description = "The name of the CloudWatch log group for tunnel logs"
  value       = var.enable_tunnel_logging && var.create_vpn_connection ? aws_cloudwatch_log_group.tunnel_logs[0].name : null
}

output "tunnel_log_group_arn" {
  description = "The ARN of the CloudWatch log group for tunnel logs"
  value       = var.enable_tunnel_logging && var.create_vpn_connection ? aws_cloudwatch_log_group.tunnel_logs[0].arn : null
}
