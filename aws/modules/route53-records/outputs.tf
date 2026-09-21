# ------------------------------------------------------------------------------
# ROUTE53 RECORDS OUTPUTS
# ------------------------------------------------------------------------------

output "records" {
  description = "Map of created DNS records"
  value = {
    for k, v in aws_route53_record.main : k => {
      name    = v.name
      type    = v.type
      fqdn    = v.fqdn
      ttl     = v.ttl
      records = v.records
    }
  }
}

output "fqdns" {
  description = "Map of record keys to FQDNs"
  value       = { for k, v in aws_route53_record.main : k => v.fqdn }
}
