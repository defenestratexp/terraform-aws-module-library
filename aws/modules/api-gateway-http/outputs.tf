# ------------------------------------------------------------------------------
# API GATEWAY HTTP API OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the HTTP API"
  value       = aws_apigatewayv2_api.main.id
}

output "arn" {
  description = "The ARN of the HTTP API"
  value       = aws_apigatewayv2_api.main.arn
}

output "name" {
  description = "The name of the HTTP API"
  value       = aws_apigatewayv2_api.main.name
}

output "api_endpoint" {
  description = "The default endpoint URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "execution_arn" {
  description = "The execution ARN for Lambda permissions"
  value       = aws_apigatewayv2_api.main.execution_arn
}

# ------------------------------------------------------------------------------
# STAGE OUTPUTS
# ------------------------------------------------------------------------------

output "stage_ids" {
  description = "Map of stage names to IDs"
  value       = { for k, v in aws_apigatewayv2_stage.main : k => v.id }
}

output "stage_invoke_urls" {
  description = "Map of stage names to invoke URLs"
  value       = { for k, v in aws_apigatewayv2_stage.main : k => v.invoke_url }
}

output "invoke_url" {
  description = "The invoke URL of the default stage"
  value       = try(aws_apigatewayv2_stage.main["$default"].invoke_url, null)
}

# ------------------------------------------------------------------------------
# ROUTE OUTPUTS
# ------------------------------------------------------------------------------

output "route_ids" {
  description = "Map of route keys to IDs"
  value       = { for k, v in aws_apigatewayv2_route.main : k => v.id }
}

output "integration_ids" {
  description = "Map of route keys to integration IDs"
  value       = { for k, v in aws_apigatewayv2_integration.main : k => v.id }
}

# ------------------------------------------------------------------------------
# AUTHORIZER OUTPUTS
# ------------------------------------------------------------------------------

output "authorizer_ids" {
  description = "Map of authorizer names to IDs"
  value       = { for k, v in aws_apigatewayv2_authorizer.main : k => v.id }
}

# ------------------------------------------------------------------------------
# VPC LINK OUTPUTS
# ------------------------------------------------------------------------------

output "vpc_link_ids" {
  description = "Map of VPC link names to IDs"
  value       = { for k, v in aws_apigatewayv2_vpc_link.main : k => v.id }
}

# ------------------------------------------------------------------------------
# CUSTOM DOMAIN OUTPUTS
# ------------------------------------------------------------------------------

output "domain_names" {
  description = "Map of custom domain configurations"
  value = { for k, v in aws_apigatewayv2_domain_name.main : k => {
    domain_name               = v.domain_name
    domain_name_configuration = v.domain_name_configuration
  } }
}

output "domain_api_mappings" {
  description = "Map of domain API mapping configurations"
  value = { for k, v in aws_apigatewayv2_api_mapping.main : k => {
    id              = v.id
    api_mapping_key = v.api_mapping_key
  } }
}
