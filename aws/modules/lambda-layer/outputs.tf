# ------------------------------------------------------------------------------
# LAMBDA LAYER OUTPUTS
# ------------------------------------------------------------------------------

output "arn" {
  description = "The ARN of the Lambda layer with version"
  value       = aws_lambda_layer_version.main.arn
}

output "layer_arn" {
  description = "The ARN of the Lambda layer without version"
  value       = aws_lambda_layer_version.main.layer_arn
}

output "version" {
  description = "The version number of the layer"
  value       = aws_lambda_layer_version.main.version
}

output "layer_name" {
  description = "The name of the layer"
  value       = aws_lambda_layer_version.main.layer_name
}

output "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the layer package"
  value       = aws_lambda_layer_version.main.source_code_hash
}

output "source_code_size" {
  description = "Size in bytes of the layer package"
  value       = aws_lambda_layer_version.main.source_code_size
}

output "created_date" {
  description = "The date the layer version was created"
  value       = aws_lambda_layer_version.main.created_date
}

output "compatible_runtimes" {
  description = "List of compatible runtimes"
  value       = aws_lambda_layer_version.main.compatible_runtimes
}

output "compatible_architectures" {
  description = "List of compatible architectures"
  value       = aws_lambda_layer_version.main.compatible_architectures
}
