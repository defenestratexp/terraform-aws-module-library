# VPC Module

Creates a VPC with public and private subnets across multiple availability zones.

## Features

- VPC with configurable CIDR block
- Internet Gateway for public internet access
- Public subnets (one per AZ) with auto-assign public IP
- Private subnets (one per AZ) for internal resources
- Optional database subnets with RDS subnet group
- Route tables with proper associations
- Auto-calculated subnet CIDRs (or specify manually)
- Consistent naming and tagging

## Usage

### Basic Usage

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc?ref=v1.0.0"

  name       = "acme-prod"
  cidr_block = "10.0.0.0/16"
}
```

Creates:
- VPC: `10.0.0.0/16`
- 2 public subnets: `10.0.0.0/20`, `10.0.16.0/20`
- 2 private subnets: `10.0.32.0/20`, `10.0.48.0/20`
- Internet Gateway
- Route tables with proper associations

### With Database Subnets

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc?ref=v1.0.0"

  name                    = "acme-prod"
  cidr_block              = "10.0.0.0/16"
  create_database_subnets = true

  tags = {
    Environment = "production"
    Client      = "ACME Corp"
  }
}
```

### Custom Availability Zones

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc?ref=v1.0.0"

  name               = "acme-prod"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
```

### Manual Subnet CIDRs

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc?ref=v1.0.0"

  name       = "acme-prod"
  cidr_block = "10.0.0.0/16"

  availability_zones   = ["us-west-2a", "us-west-2b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}
```

## Wiring with Other Modules

### With NAT Gateway

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc?ref=v1.0.0"

  name       = "acme-prod"
  cidr_block = "10.0.0.0/16"
}

module "nat" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nat-gateway?ref=v1.0.0"

  name                    = "acme-prod"
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
}
```

### With Security Group

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc?ref=v1.0.0"

  name       = "acme-prod"
  cidr_block = "10.0.0.0/16"
}

module "web_sg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/security-group?ref=v1.0.0"

  name   = "acme-prod-web"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| cidr_block | CIDR block for the VPC | `string` | n/a | yes |
| availability_zones | List of AZs to use (default: first 2 in region) | `list(string)` | `[]` | no |
| public_subnet_cidrs | CIDR blocks for public subnets (auto-calculated if empty) | `list(string)` | `[]` | no |
| private_subnet_cidrs | CIDR blocks for private subnets (auto-calculated if empty) | `list(string)` | `[]` | no |
| create_database_subnets | Create a third tier of database subnets | `bool` | `false` | no |
| database_subnet_cidrs | CIDR blocks for database subnets (auto-calculated if empty) | `list(string)` | `[]` | no |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| instance_tenancy | Tenancy option (default, dedicated, host) | `string` | `"default"` | no |
| map_public_ip_on_launch | Auto-assign public IP in public subnets | `bool` | `true` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the VPC |
| arn | The ARN of the VPC |
| vpc_id | Alias for id (convenience) |
| cidr_block | The CIDR block of the VPC |
| name | The name of the VPC |
| internet_gateway_id | The ID of the Internet Gateway |
| public_subnet_ids | List of public subnet IDs |
| public_subnet_arns | List of public subnet ARNs |
| public_subnet_cidr_blocks | List of public subnet CIDR blocks |
| private_subnet_ids | List of private subnet IDs |
| private_subnet_arns | List of private subnet ARNs |
| private_subnet_cidr_blocks | List of private subnet CIDR blocks |
| database_subnet_ids | List of database subnet IDs |
| database_subnet_arns | List of database subnet ARNs |
| database_subnet_cidr_blocks | List of database subnet CIDR blocks |
| database_subnet_group_name | Name of the RDS subnet group |
| public_route_table_id | ID of the public route table |
| private_route_table_ids | List of private route table IDs (one per AZ) |
| availability_zones | List of availability zones used |
| az_count | Number of availability zones |
| subnets | Map of all subnet information by tier |

## Architecture

```
                    Internet
                        │
                        ▼
                ┌───────────────┐
                │    Internet   │
                │    Gateway    │
                └───────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────────┬───────────────┬───────────────┐
│   Public-1    │   Public-2    │   Public-3    │
│  10.0.0.0/20  │ 10.0.16.0/20  │ 10.0.32.0/20  │
│    (AZ-a)     │    (AZ-b)     │    (AZ-c)     │
└───────────────┴───────────────┴───────────────┘
        │               │               │
        ▼               ▼               ▼
┌───────────────┬───────────────┬───────────────┐
│   Private-1   │   Private-2   │   Private-3   │
│ 10.0.48.0/20  │ 10.0.64.0/20  │ 10.0.80.0/20  │
│    (AZ-a)     │    (AZ-b)     │    (AZ-c)     │
└───────────────┴───────────────┴───────────────┘
        │               │               │
        ▼               ▼               ▼
┌───────────────┬───────────────┬───────────────┐
│  Database-1   │  Database-2   │  Database-3   │
│ 10.0.96.0/20  │ 10.0.112.0/20 │ 10.0.128.0/20 │
│    (AZ-a)     │    (AZ-b)     │    (AZ-c)     │
└───────────────┴───────────────┴───────────────┘
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- Private subnets have no internet access by default. Use the `nat-gateway` module to enable outbound access.
- Each AZ gets its own private route table to support AZ-specific NAT Gateways.
- Database subnets share route tables with private subnets.
- Subnet CIDRs are auto-calculated using /20 blocks within the VPC CIDR.
