# Network Load Balancer Module

Creates a Network Load Balancer with TCP/UDP/TLS listeners.

## Features

- Layer 4 (TCP/UDP/TLS) load balancing
- Static IP support with Elastic IPs
- Cross-zone load balancing
- Client IP preservation
- TLS termination support
- Access logging to S3
- Consistent naming and tagging

## Usage

### Basic TCP Listener

```hcl
module "nlb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nlb?ref=v1.0.0"

  name       = "acme-prod-tcp"
  subnet_ids = module.vpc.public_subnet_ids

  listeners = [
    {
      port             = 443
      protocol         = "TCP"
      target_group_arn = module.target_group.arn
    }
  ]
}
```

### Multiple Listeners

```hcl
module "nlb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nlb?ref=v1.0.0"

  name       = "acme-prod-multi"
  subnet_ids = module.vpc.public_subnet_ids

  listeners = [
    {
      port             = 80
      protocol         = "TCP"
      target_group_arn = module.http_target_group.arn
    },
    {
      port             = 443
      protocol         = "TCP"
      target_group_arn = module.https_target_group.arn
    },
    {
      port             = 3306
      protocol         = "TCP"
      target_group_arn = module.mysql_target_group.arn
    }
  ]
}
```

### TLS Termination

```hcl
module "nlb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nlb?ref=v1.0.0"

  name       = "acme-prod-tls"
  subnet_ids = module.vpc.public_subnet_ids

  listeners = [
    {
      port             = 443
      protocol         = "TLS"
      target_group_arn = module.target_group.arn
      certificate_arn  = aws_acm_certificate.main.arn
    }
  ]
}
```

### With Static Elastic IPs

```hcl
resource "aws_eip" "nlb" {
  count  = 2
  domain = "vpc"
}

module "nlb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nlb?ref=v1.0.0"

  name       = "acme-prod-static"
  subnet_ids = module.vpc.public_subnet_ids

  use_elastic_ips           = true
  elastic_ip_allocation_ids = aws_eip.nlb[*].allocation_id

  listeners = [
    {
      port             = 443
      protocol         = "TCP"
      target_group_arn = module.target_group.arn
    }
  ]
}
```

### Internal NLB

```hcl
module "nlb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nlb?ref=v1.0.0"

  name       = "acme-prod-internal"
  subnet_ids = module.vpc.private_subnet_ids
  internal   = true

  listeners = [
    {
      port             = 5432
      protocol         = "TCP"
      target_group_arn = module.postgres_target_group.arn
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the NLB | `string` | n/a | yes |
| subnet_ids | Subnet IDs | `list(string)` | n/a | yes |
| internal | Create internal NLB | `bool` | `false` | no |
| enable_deletion_protection | Enable deletion protection | `bool` | `false` | no |
| enable_cross_zone_load_balancing | Enable cross-zone LB | `bool` | `true` | no |
| enable_client_ip_preservation | Preserve client IP | `bool` | `true` | no |
| use_elastic_ips | Use Elastic IPs | `bool` | `false` | no |
| elastic_ip_allocation_ids | EIP allocation IDs | `list(string)` | `[]` | no |
| listeners | List of listeners | `list(object)` | `[]` | no |
| enable_access_logs | Enable access logs | `bool` | `false` | no |
| access_logs_bucket | S3 bucket for logs | `string` | `""` | no |
| access_logs_prefix | S3 prefix for logs | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

### Listener Object

```hcl
{
  port             = number       # Required: Port number
  protocol         = string       # Required: TCP, UDP, TLS, TCP_UDP
  target_group_arn = string       # Required: Target group ARN
  certificate_arn  = string       # Optional: ACM cert for TLS
  ssl_policy       = string       # Optional: SSL policy for TLS
  alpn_policy      = string       # Optional: ALPN policy
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the load balancer |
| arn | The ARN of the load balancer |
| arn_suffix | ARN suffix for CloudWatch |
| name | The name of the load balancer |
| dns_name | The DNS name |
| zone_id | Zone ID for Route53 alias |
| listener_arns | List of listener ARNs |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- NLB does not require security groups (traffic goes directly to targets).
- Use Elastic IPs for static IP addresses (useful for firewall whitelisting).
- Cross-zone load balancing is enabled by default.
- NLB preserves client IP by default (unlike ALB).
- TLS termination requires an ACM certificate.
