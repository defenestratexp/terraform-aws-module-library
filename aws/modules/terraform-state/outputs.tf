# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------

output "bucket_name" {
  description = "Name of the S3 bucket for state storage"
  value       = aws_s3_bucket.state.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.state.arn
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.state.region
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.lock.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.lock.arn
}

# Convenience output for backend configuration
output "backend_config" {
  description = "Backend configuration snippet for use in other Terraform configurations"
  value = {
    bucket         = aws_s3_bucket.state.id
    dynamodb_table = aws_dynamodb_table.lock.name
    region         = aws_s3_bucket.state.region
    encrypt        = true
  }
}

output "backend_config_hcl" {
  description = "HCL snippet for backend configuration (copy into backend.tf)"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.state.id}"
        key            = "<environment>/terraform.tfstate"
        region         = "${aws_s3_bucket.state.region}"
        dynamodb_table = "${aws_dynamodb_table.lock.name}"
        encrypt        = true
      }
    }
  EOT
}
