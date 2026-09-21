# ACM Certificate Module

Creates an ACM SSL/TLS certificate with optional DNS validation via Route53.

## Usage

### Basic Certificate (Manual DNS Validation)

```hcl
module "certificate" {
  source = "path/to/modules/acm-certificate"

  domain_name = "example.com"

  subject_alternative_names = [
    "www.example.com",
    "api.example.com"
  ]

  tags = {
    Environment = "production"
  }
}

# Output DNS validation records to create manually
output "validation_records" {
  value = module.certificate.domain_validation_options
}
```

### Certificate with Automatic Route53 Validation

```hcl
module "certificate" {
  source = "path/to/modules/acm-certificate"

  domain_name = "example.com"

  subject_alternative_names = [
    "www.example.com",
    "*.example.com"
  ]

  create_route53_records = true
  route53_zone_id        = data.aws_route53_zone.main.zone_id
}

data "aws_route53_zone" "main" {
  name = "example.com"
}
```

### Wildcard Certificate

```hcl
module "wildcard_cert" {
  source = "path/to/modules/acm-certificate"

  domain_name = "*.example.com"

  subject_alternative_names = [
    "example.com"  # Include apex domain
  ]

  create_route53_records = true
  route53_zone_id        = data.aws_route53_zone.main.zone_id
}
```

### Certificate with ECC Key

```hcl
module "ecc_certificate" {
  source = "path/to/modules/acm-certificate"

  domain_name   = "secure.example.com"
  key_algorithm = "EC_prime256v1"

  create_route53_records = true
  route53_zone_id        = data.aws_route53_zone.main.zone_id
}
```

### Certificate without Waiting for Validation

```hcl
module "async_certificate" {
  source = "path/to/modules/acm-certificate"

  domain_name = "example.com"

  # Don't wait - useful when DNS is managed elsewhere
  wait_for_validation = false
}
```

### Using with ALB

```hcl
module "certificate" {
  source = "path/to/modules/acm-certificate"

  domain_name            = "app.example.com"
  create_route53_records = true
  route53_zone_id        = data.aws_route53_zone.main.zone_id
}

module "alb" {
  source = "path/to/modules/alb"

  name = "my-alb"

  # ... other settings

  https_listeners = [
    {
      port            = 443
      certificate_arn = module.certificate.validated_arn
      default_action = {
        type             = "forward"
        target_group_arn = module.target_group.arn
      }
    }
  ]
}
```

### Using with CloudFront (us-east-1)

```hcl
# CloudFront requires certificates in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront_certificate" {
  source = "path/to/modules/acm-certificate"

  providers = {
    aws = aws.us_east_1
  }

  domain_name = "cdn.example.com"

  # Can still use Route53 zone in any region
  create_route53_records = true
  route53_zone_id        = data.aws_route53_zone.main.zone_id
}
```

### Multi-Domain Certificate

```hcl
module "multi_domain_cert" {
  source = "path/to/modules/acm-certificate"

  domain_name = "example.com"

  subject_alternative_names = [
    "www.example.com",
    "api.example.com",
    "admin.example.com",
    "*.staging.example.com"
  ]

  create_route53_records = true
  route53_zone_id        = data.aws_route53_zone.main.zone_id
}
```

## Features

- **DNS Validation**: Automatic or manual DNS validation
- **Route53 Integration**: Create validation records automatically
- **Multiple Domains**: Support for SANs and wildcards
- **Key Algorithms**: RSA and ECC key options
- **Transparency Logging**: Certificate transparency support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | Primary domain name | `string` | n/a | yes |
| subject_alternative_names | Additional domain names (SANs) | `list(string)` | `[]` | no |
| validation_method | Validation method (DNS or EMAIL) | `string` | `"DNS"` | no |
| create_route53_records | Create Route53 validation records | `bool` | `false` | no |
| route53_zone_id | Route53 zone ID for validation | `string` | `""` | no |
| wait_for_validation | Wait for validation to complete | `bool` | `true` | no |
| validation_timeout | Timeout for validation | `string` | `"45m"` | no |
| key_algorithm | Key algorithm | `string` | `"RSA_2048"` | no |
| certificate_transparency_logging_preference | CT logging preference | `string` | `"ENABLED"` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the certificate |
| arn | The ARN of the certificate |
| domain_name | The domain name |
| status | Status of the certificate |
| domain_validation_options | DNS validation options |
| validation_emails | Email addresses for email validation |
| not_after | Certificate expiration date |
| not_before | Certificate start date |
| validated_arn | ARN after validation completes |

## Key Algorithms

| Algorithm | Type | Use Case |
|-----------|------|----------|
| RSA_2048 | RSA | Default, widely compatible |
| EC_prime256v1 | ECDSA | Faster, smaller keys |
| EC_secp384r1 | ECDSA | Higher security |
| EC_secp521r1 | ECDSA | Highest security |

## DNS Validation Records

When using manual DNS validation, create CNAME records with:

| Field | Value |
|-------|-------|
| Name | `domain_validation_options[].resource_record_name` |
| Type | `CNAME` |
| Value | `domain_validation_options[].resource_record_value` |

## Notes

- DNS validation is recommended over email validation
- Certificates automatically renew 60 days before expiration
- CloudFront requires certificates in `us-east-1`
- Wildcard certificates (`*.example.com`) don't cover the apex (`example.com`)
