# ------------------------------------------------------------------------------
# API GATEWAY REST API OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "arn" {
  description = "The ARN of the REST API"
  value       = aws_api_gateway_rest_api.main.arn
}

output "name" {
  description = "The name of the REST API"
  value       = aws_api_gateway_rest_api.main.name
}

output "root_resource_id" {
  description = "The root resource ID"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}

output "execution_arn" {
  description = "The execution ARN for Lambda permissions"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

# ------------------------------------------------------------------------------
# DEPLOYMENT OUTPUTS
# ------------------------------------------------------------------------------

output "deployment_id" {
  description = "The deployment ID"
  value       = var.create_deployment ? aws_api_gateway_deployment.main[0].id : null
}

# ------------------------------------------------------------------------------
# STAGE OUTPUTS
# ------------------------------------------------------------------------------

output "stage_arns" {
  description = "Map of stage names to ARNs"
  value       = { for k, v in aws_api_gateway_stage.main : k => v.arn }
}

output "stage_invoke_urls" {
  description = "Map of stage names to invoke URLs"
  value       = { for k, v in aws_api_gateway_stage.main : k => v.invoke_url }
}

output "invoke_url" {
  description = "The invoke URL of the first stage (convenience output)"
  value       = length(aws_api_gateway_stage.main) > 0 ? values(aws_api_gateway_stage.main)[0].invoke_url : null
}

# ------------------------------------------------------------------------------
# CUSTOM DOMAIN OUTPUTS
# ------------------------------------------------------------------------------

output "domain_names" {
  description = "Map of custom domain configurations"
  value = { for k, v in aws_api_gateway_domain_name.main : k => {
    domain_name            = v.domain_name
    regional_domain_name   = v.regional_domain_name
    regional_zone_id       = v.regional_zone_id
    cloudfront_domain_name = v.cloudfront_domain_name
    cloudfront_zone_id     = v.cloudfront_zone_id
  } }
}

# ------------------------------------------------------------------------------
# API KEY OUTPUTS
# ------------------------------------------------------------------------------

output "api_key_ids" {
  description = "Map of API key names to IDs"
  value       = { for k, v in aws_api_gateway_api_key.main : k => v.id }
}

output "api_key_values" {
  description = "Map of API key names to values"
  value       = { for k, v in aws_api_gateway_api_key.main : k => v.value }
  sensitive   = true
}

# ------------------------------------------------------------------------------
# USAGE PLAN OUTPUTS
# ------------------------------------------------------------------------------

output "usage_plan_ids" {
  description = "Map of usage plan names to IDs"
  value       = { for k, v in aws_api_gateway_usage_plan.main : k => v.id }
}
