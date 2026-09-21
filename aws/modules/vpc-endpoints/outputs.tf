# ------------------------------------------------------------------------------
# VPC ENDPOINTS OUTPUTS
# ------------------------------------------------------------------------------

output "gateway_endpoints" {
  description = "Map of gateway endpoint details"
  value = {
    for k, v in aws_vpc_endpoint.gateway : k => {
      id             = v.id
      arn            = v.arn
      prefix_list_id = v.prefix_list_id
      state          = v.state
    }
  }
}

output "interface_endpoints" {
  description = "Map of interface endpoint details"
  value = {
    for k, v in aws_vpc_endpoint.interface : k => {
      id                    = v.id
      arn                   = v.arn
      dns_entry             = v.dns_entry
      network_interface_ids = v.network_interface_ids
      state                 = v.state
    }
  }
}

output "gateway_endpoint_ids" {
  description = "Map of gateway endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}

output "interface_endpoint_ids" {
  description = "Map of interface endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "s3_endpoint_prefix_list_id" {
  description = "Prefix list ID for S3 gateway endpoint (if created)"
  value       = try(aws_vpc_endpoint.gateway["s3"].prefix_list_id, null)
}

output "dynamodb_endpoint_prefix_list_id" {
  description = "Prefix list ID for DynamoDB gateway endpoint (if created)"
  value       = try(aws_vpc_endpoint.gateway["dynamodb"].prefix_list_id, null)
}
