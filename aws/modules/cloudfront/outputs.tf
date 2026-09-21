# ------------------------------------------------------------------------------
# CLOUDFRONT OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The identifier for the distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "arn" {
  description = "The ARN of the distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "domain_name" {
  description = "The domain name of the distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "hosted_zone_id" {
  description = "The CloudFront Route53 zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "status" {
  description = "The status of the distribution"
  value       = aws_cloudfront_distribution.main.status
}

output "etag" {
  description = "The current version of the distribution's information"
  value       = aws_cloudfront_distribution.main.etag
}

output "caller_reference" {
  description = "Internal value used by CloudFront to track updates"
  value       = aws_cloudfront_distribution.main.caller_reference
}
