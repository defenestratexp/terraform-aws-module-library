# ------------------------------------------------------------------------------
# VPC PEERING OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.main.id
}

output "accept_status" {
  description = "The status of the peering connection"
  value       = aws_vpc_peering_connection.main.accept_status
}

output "requester_vpc_id" {
  description = "The ID of the requester VPC"
  value       = aws_vpc_peering_connection.main.vpc_id
}

output "accepter_vpc_id" {
  description = "The ID of the accepter VPC"
  value       = aws_vpc_peering_connection.main.peer_vpc_id
}

output "requester_cidr_block" {
  description = "The CIDR block of the requester VPC"
  value       = var.requester_cidr_block
}

output "accepter_cidr_block" {
  description = "The CIDR block of the accepter VPC"
  value       = var.accepter_cidr_block
}
