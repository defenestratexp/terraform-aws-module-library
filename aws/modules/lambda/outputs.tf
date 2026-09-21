# ------------------------------------------------------------------------------
# LAMBDA FUNCTION OUTPUTS
# ------------------------------------------------------------------------------

output "arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = aws_lambda_function.main.qualified_arn
}

output "version" {
  description = "The published version of the Lambda function"
  value       = aws_lambda_function.main.version
}

output "last_modified" {
  description = "The date Lambda function was last modified"
  value       = aws_lambda_function.main.last_modified
}

output "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  value       = aws_lambda_function.main.source_code_hash
}

output "source_code_size" {
  description = "Size in bytes of the function deployment package"
  value       = aws_lambda_function.main.source_code_size
}

# ------------------------------------------------------------------------------
# IAM OUTPUTS
# ------------------------------------------------------------------------------

output "role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = local.role_arn
}

output "role_name" {
  description = "The name of the Lambda execution role"
  value       = var.create_role ? aws_iam_role.lambda[0].name : null
}

# ------------------------------------------------------------------------------
# LOGGING OUTPUTS
# ------------------------------------------------------------------------------

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.arn
}

# ------------------------------------------------------------------------------
# FUNCTION URL OUTPUTS
# ------------------------------------------------------------------------------

output "function_url" {
  description = "The Lambda function URL"
  value       = var.create_function_url ? aws_lambda_function_url.main[0].function_url : null
}

output "function_url_id" {
  description = "The Lambda function URL ID"
  value       = var.create_function_url ? aws_lambda_function_url.main[0].url_id : null
}

# ------------------------------------------------------------------------------
# EVENT SOURCE MAPPING OUTPUTS
# ------------------------------------------------------------------------------

output "event_source_mapping_ids" {
  description = "Map of event source mapping UUIDs"
  value       = { for k, v in aws_lambda_event_source_mapping.main : k => v.uuid }
}
