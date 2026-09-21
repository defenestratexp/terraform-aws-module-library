# ------------------------------------------------------------------------------
# ACM CERTIFICATE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the certificate"
  value       = aws_acm_certificate.main.id
}

output "arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.main.arn
}

output "domain_name" {
  description = "The domain name for which the certificate is issued"
  value       = aws_acm_certificate.main.domain_name
}

output "status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "domain_validation_options" {
  description = "Domain validation options for DNS validation"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "validation_emails" {
  description = "Email addresses for email validation"
  value       = aws_acm_certificate.main.validation_emails
}

output "not_after" {
  description = "Expiration date and time of the certificate"
  value       = aws_acm_certificate.main.not_after
}

output "not_before" {
  description = "Start date and time of the certificate"
  value       = aws_acm_certificate.main.not_before
}

output "validated_arn" {
  description = "The ARN of the validated certificate (after validation completes)"
  value       = var.wait_for_validation ? aws_acm_certificate_validation.main[0].certificate_arn : aws_acm_certificate.main.arn
}
