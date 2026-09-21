# Route53 Zone Module

Creates a Route53 hosted zone (public or private) with optional DNSSEC and query logging.

## Usage

### Public Hosted Zone

```hcl
module "public_zone" {
  source = "path/to/modules/route53-zone"

  name = "example.com"

  tags = {
    Environment = "production"
  }
}

output "name_servers" {
  value = module.public_zone.name_servers
}
```

### Private Hosted Zone

```hcl
module "private_zone" {
  source = "path/to/modules/route53-zone"

  name       = "internal.example.com"
  is_private = true

  vpc_associations = [
    {
      vpc_id = module.vpc.id
    }
  ]
}
```

### Private Zone with Multiple VPCs

```hcl
module "shared_private_zone" {
  source = "path/to/modules/route53-zone"

  name       = "internal.corp"
  is_private = true

  vpc_associations = [
    {
      vpc_id     = module.vpc_prod.id
      vpc_region = "us-east-1"
    },
    {
      vpc_id     = module.vpc_dev.id
      vpc_region = "us-west-2"
    }
  ]
}
```

### Zone with DNSSEC

```hcl
module "secure_zone" {
  source = "path/to/modules/route53-zone"

  name         = "secure.example.com"
  enable_dnssec = true
}

# Add DS record to parent zone
output "ds_record" {
  value = module.secure_zone.dnssec_ds_record
}
```

### Zone with Query Logging

```hcl
resource "aws_cloudwatch_log_group" "dns_logs" {
  name              = "/aws/route53/${var.domain_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_resource_policy" "dns_logs" {
  policy_name = "route53-query-logging"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.dns_logs.arn}:*"
      }
    ]
  })
}

module "logged_zone" {
  source = "path/to/modules/route53-zone"

  name                 = "example.com"
  enable_query_logging = true
  query_log_group_arn  = aws_cloudwatch_log_group.dns_logs.arn

  depends_on = [aws_cloudwatch_log_resource_policy.dns_logs]
}
```

### Using with Delegation Set

```hcl
resource "aws_route53_delegation_set" "main" {
  reference_name = "main"
}

module "zone1" {
  source = "path/to/modules/route53-zone"

  name              = "example1.com"
  delegation_set_id = aws_route53_delegation_set.main.id
}

module "zone2" {
  source = "path/to/modules/route53-zone"

  name              = "example2.com"
  delegation_set_id = aws_route53_delegation_set.main.id
}
```

## Features

- **Public Zones**: Internet-facing DNS resolution
- **Private Zones**: VPC-only DNS resolution
- **DNSSEC**: DNS Security Extensions signing
- **Query Logging**: CloudWatch Logs integration
- **Delegation Sets**: Reusable name server sets

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Domain name for the hosted zone | `string` | n/a | yes |
| is_private | Create a private hosted zone | `bool` | `false` | no |
| vpc_associations | VPCs to associate with private zone | `list(object)` | `[]` | no |
| delegation_set_id | ID of a reusable delegation set | `string` | `""` | no |
| enable_dnssec | Enable DNSSEC signing | `bool` | `false` | no |
| enable_query_logging | Enable query logging | `bool` | `false` | no |
| query_log_group_arn | CloudWatch Logs group ARN | `string` | `""` | no |
| comment | Comment for the hosted zone | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| zone_id | The hosted zone ID |
| name | The domain name of the zone |
| name_servers | List of name servers |
| arn | The ARN of the hosted zone |
| primary_name_server | The primary name server |
| dnssec_key_signing_key_id | The DNSSEC KSK ID |
| dnssec_ds_record | The DS record for parent zone |

## DNSSEC Setup

After enabling DNSSEC, you need to add the DS record to your domain registrar or parent zone:

1. Get the DS record from the output
2. Add it to your domain registrar's DNS settings
3. Wait for propagation (can take up to 48 hours)

## Query Logging Notes

- Query logging must be set up in `us-east-1` region
- CloudWatch Logs group must have the appropriate resource policy
- Logs include: query timestamp, hosted zone ID, query name, query type, response code
