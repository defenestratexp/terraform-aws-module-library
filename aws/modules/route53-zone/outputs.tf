# ------------------------------------------------------------------------------
# ROUTE53 ZONE OUTPUTS
# ------------------------------------------------------------------------------

output "zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name" {
  description = "The domain name of the zone"
  value       = aws_route53_zone.main.name
}

output "name_servers" {
  description = "List of name servers for the zone"
  value       = aws_route53_zone.main.name_servers
}

output "arn" {
  description = "The ARN of the hosted zone"
  value       = aws_route53_zone.main.arn
}

output "primary_name_server" {
  description = "The primary name server for the zone"
  value       = aws_route53_zone.main.primary_name_server
}

output "dnssec_key_signing_key_id" {
  description = "The ID of the DNSSEC key signing key"
  value       = var.enable_dnssec && !var.is_private ? aws_route53_key_signing_key.main[0].id : null
}

output "dnssec_ds_record" {
  description = "The DS record for DNSSEC (to add to parent zone)"
  value       = var.enable_dnssec && !var.is_private ? aws_route53_key_signing_key.main[0].ds_record : null
}
