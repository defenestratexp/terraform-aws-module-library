# ------------------------------------------------------------------------------
# S3 BUCKET OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.main.id
}

output "arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.main.region
}

output "website_endpoint" {
  description = "The website endpoint, if website hosting is enabled"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.main[0].website_endpoint : null
}

output "website_domain" {
  description = "The domain of the website endpoint, if website hosting is enabled"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.main[0].website_domain : null
}
