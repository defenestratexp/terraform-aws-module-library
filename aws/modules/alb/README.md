# Application Load Balancer Module

Creates an Application Load Balancer with HTTP and/or HTTPS listeners.

## Features

- Internet-facing or internal ALB
- HTTP listener with redirect or forward action
- HTTPS listener with TLS 1.3 by default
- Multiple certificate support (SNI)
- Access logging to S3
- HTTP/2 enabled by default
- Security headers (drop invalid headers)
- Consistent naming and tagging

## Usage

### Basic HTTP Only

```hcl
module "alb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/alb?ref=v1.0.0"

  name               = "acme-prod-web"
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.id]

  http_listener_action           = "forward"
  http_listener_target_group_arn = module.target_group.arn
}
```

### HTTPS with HTTP Redirect

```hcl
module "alb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/alb?ref=v1.0.0"

  name               = "acme-prod-web"
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.id]

  # HTTP listener redirects to HTTPS
  create_http_listener = true
  http_listener_action = "redirect"

  # HTTPS listener forwards to target group
  create_https_listener           = true
  https_listener_certificate_arn  = aws_acm_certificate.main.arn
  https_listener_target_group_arn = module.target_group.arn
}
```

### Internal Load Balancer

```hcl
module "alb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/alb?ref=v1.0.0"

  name               = "acme-prod-internal"
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.internal_alb_sg.id]
  internal           = true

  create_https_listener = false
  http_listener_action           = "forward"
  http_listener_target_group_arn = module.target_group.arn
}
```

### With Access Logs

```hcl
module "alb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/alb?ref=v1.0.0"

  name               = "acme-prod-web"
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.id]

  enable_access_logs = true
  access_logs_bucket = aws_s3_bucket.logs.id
  access_logs_prefix = "alb/acme-prod-web"

  create_https_listener           = true
  https_listener_certificate_arn  = aws_acm_certificate.main.arn
  https_listener_target_group_arn = module.target_group.arn
}
```

### With Multiple Certificates (SNI)

```hcl
module "alb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/alb?ref=v1.0.0"

  name               = "acme-prod-web"
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.id]

  create_https_listener           = true
  https_listener_certificate_arn  = aws_acm_certificate.primary.arn
  https_listener_target_group_arn = module.target_group.arn

  additional_certificates = [
    aws_acm_certificate.secondary.arn,
    aws_acm_certificate.tertiary.arn,
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ALB | `string` | n/a | yes |
| subnet_ids | Subnet IDs (min 2 AZs) | `list(string)` | n/a | yes |
| security_group_ids | Security group IDs | `list(string)` | n/a | yes |
| internal | Create internal ALB | `bool` | `false` | no |
| enable_deletion_protection | Enable deletion protection | `bool` | `false` | no |
| enable_http2 | Enable HTTP/2 | `bool` | `true` | no |
| idle_timeout | Idle timeout in seconds | `number` | `60` | no |
| drop_invalid_header_fields | Drop invalid headers | `bool` | `true` | no |
| preserve_host_header | Preserve Host header | `bool` | `false` | no |
| enable_access_logs | Enable access logs | `bool` | `false` | no |
| access_logs_bucket | S3 bucket for logs | `string` | `""` | no |
| access_logs_prefix | S3 prefix for logs | `string` | `""` | no |
| create_http_listener | Create HTTP listener | `bool` | `true` | no |
| http_listener_action | HTTP action (forward, redirect) | `string` | `"redirect"` | no |
| http_listener_target_group_arn | Target group for HTTP | `string` | `""` | no |
| create_https_listener | Create HTTPS listener | `bool` | `false` | no |
| https_listener_certificate_arn | ACM certificate ARN | `string` | `""` | no |
| https_listener_target_group_arn | Target group for HTTPS | `string` | `""` | no |
| https_listener_ssl_policy | SSL policy | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| additional_certificates | Additional cert ARNs | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the load balancer |
| arn | The ARN of the load balancer |
| arn_suffix | ARN suffix for CloudWatch |
| name | The name of the load balancer |
| dns_name | The DNS name |
| zone_id | Zone ID for Route53 alias |
| http_listener_arn | HTTP listener ARN |
| https_listener_arn | HTTPS listener ARN |
| url | The URL of the load balancer |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- ALB requires subnets in at least 2 availability zones.
- HTTP redirect to HTTPS is the default behavior.
- TLS 1.3 is enabled by default via the SSL policy.
- For Route53 alias records, use `zone_id` and `dns_name` outputs.
- Access logs bucket must have proper ALB access policy configured.
