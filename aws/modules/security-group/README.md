# Security Group Module

Creates a security group with configurable ingress and egress rules.

## Features

- Flexible ingress and egress rule configuration
- Support for CIDR blocks, security group references, and self-references
- Default allow-all egress (configurable)
- Proper rule revocation on delete
- Consistent naming and tagging

## Usage

### Basic Web Server

```hcl
module "web_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-web"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from internet"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from internet"
    }
  ]
}
```

### SSH Access from Specific IP

```hcl
module "ssh_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-ssh"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.10/32"]
      description = "SSH from office IP"
    }
  ]
}
```

### Database - Allow from App Tier

```hcl
module "app_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-app"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.id
      description              = "HTTP from ALB"
    }
  ]
}

module "db_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-db"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.app_sg.id
      description              = "PostgreSQL from app tier"
    }
  ]
}
```

### Self-Referencing (Cluster Communication)

```hcl
module "cluster_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-cluster"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      self        = true
      description = "All TCP from cluster members"
    }
  ]
}
```

### Restricted Egress

```hcl
module "restricted_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-restricted"
  vpc_id = module.vpc.vpc_id

  allow_all_egress = false

  egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS only"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the security group | `string` | n/a | yes |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| description | Description of the security group | `string` | `"Managed by Terraform"` | no |
| ingress_rules | List of ingress rules (see below) | `list(object)` | `[]` | no |
| egress_rules | List of egress rules (see below) | `list(object)` | `[]` | no |
| allow_all_egress | Add default rule allowing all outbound | `bool` | `true` | no |
| revoke_rules_on_delete | Revoke rules before deleting | `bool` | `true` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

### Rule Object Structure

```hcl
{
  from_port                = number       # Required: Start port
  to_port                  = number       # Required: End port
  protocol                 = string       # Required: "tcp", "udp", "icmp", or "-1" for all
  cidr_blocks              = list(string) # Optional: IPv4 CIDR blocks
  ipv6_cidr_blocks         = list(string) # Optional: IPv6 CIDR blocks
  source_security_group_id = string       # Optional: Source/dest security group ID
  self                     = bool         # Optional: Reference self
  description              = string       # Optional: Rule description
}
```

**Note:** Only one of `cidr_blocks`, `ipv6_cidr_blocks`, `source_security_group_id`, or `self` should be set per rule.

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the security group |
| arn | The ARN of the security group |
| name | The name of the security group |
| vpc_id | The VPC ID of the security group |
| security_group_id | Alias for id |

## Common Port Reference

| Service | Port | Protocol |
|---------|------|----------|
| HTTP | 80 | tcp |
| HTTPS | 443 | tcp |
| SSH | 22 | tcp |
| RDP | 3389 | tcp |
| PostgreSQL | 5432 | tcp |
| MySQL | 3306 | tcp |
| Redis | 6379 | tcp |
| MongoDB | 27017 | tcp |
| Elasticsearch | 9200 | tcp |
| All Traffic | 0-65535 | -1 |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- Security group rules are created as separate resources for easier management.
- By default, all outbound traffic is allowed. Set `allow_all_egress = false` to restrict.
- Use `source_security_group_id` to reference other security groups instead of CIDR blocks for better security.
- Use `self = true` for cluster communication where instances need to talk to each other.
