# NAT Gateway Module

Creates NAT Gateway(s) with Elastic IPs to provide outbound internet access for private subnets.

## Features

- Single NAT Gateway mode (cost-effective)
- High-availability mode (one NAT per AZ)
- Automatic Elastic IP allocation
- Option to reuse existing Elastic IPs
- Automatic route table updates
- Consistent naming and tagging

## Usage

### Basic Usage (HA Mode - One NAT per AZ)

```hcl
module "nat" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nat-gateway?ref=v1.0.0"

  name                    = "acme-prod"
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
}
```

### Single NAT Gateway (Cost-Effective)

```hcl
module "nat" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nat-gateway?ref=v1.0.0"

  name                    = "acme-dev"
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  single_nat_gateway      = true

  tags = {
    Environment = "development"
  }
}
```

### Reuse Existing Elastic IPs

```hcl
module "nat" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/nat-gateway?ref=v1.0.0"

  name                        = "acme-prod"
  public_subnet_ids           = module.vpc.public_subnet_ids
  private_route_table_ids     = module.vpc.private_route_table_ids
  reuse_existing_eips         = true
  existing_eip_allocation_ids = ["eipalloc-abc123", "eipalloc-def456"]
}
```

## Complete Example with VPC

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

# Now instances in private subnets can reach the internet
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| public_subnet_ids | List of public subnet IDs for NAT placement | `list(string)` | n/a | yes |
| private_route_table_ids | List of private route table IDs to update | `list(string)` | n/a | yes |
| single_nat_gateway | Use single NAT instead of one per AZ | `bool` | `false` | no |
| reuse_existing_eips | Use existing Elastic IPs | `bool` | `false` | no |
| existing_eip_allocation_ids | Existing EIP allocation IDs (if reusing) | `list(string)` | `[]` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_public_ips | List of NAT Gateway public IPs |
| eip_ids | List of Elastic IP IDs |
| eip_allocation_ids | List of Elastic IP allocation IDs |
| eip_public_ips | List of Elastic IP public addresses |
| nat_gateway_count | Number of NAT Gateways created |
| is_single_nat | Whether single NAT mode is enabled |

## Architecture

### HA Mode (Default)

```
┌─────────────────────────────────────────────────────┐
│                       VPC                           │
├─────────────────────────────────────────────────────┤
│                                                     │
│   Public Subnets                                    │
│   ┌─────────────┐  ┌─────────────┐                 │
│   │  NAT GW 1   │  │  NAT GW 2   │                 │
│   │  (EIP 1)    │  │  (EIP 2)    │                 │
│   │   AZ-a      │  │   AZ-b      │                 │
│   └──────┬──────┘  └──────┬──────┘                 │
│          │                │                         │
│   ───────┼────────────────┼─────────               │
│          │                │                         │
│   Private Subnets         │                         │
│   ┌──────┴──────┐  ┌──────┴──────┐                 │
│   │  Private 1  │  │  Private 2  │                 │
│   │  Route → 1  │  │  Route → 2  │                 │
│   │   AZ-a      │  │   AZ-b      │                 │
│   └─────────────┘  └─────────────┘                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Single NAT Mode

```
┌─────────────────────────────────────────────────────┐
│                       VPC                           │
├─────────────────────────────────────────────────────┤
│                                                     │
│   Public Subnets                                    │
│   ┌─────────────┐  ┌─────────────┐                 │
│   │  NAT GW 1   │  │             │                 │
│   │  (EIP 1)    │  │   (none)    │                 │
│   │   AZ-a      │  │   AZ-b      │                 │
│   └──────┬──────┘  └─────────────┘                 │
│          │                                          │
│   ───────┼──────────────────────────               │
│          │                                          │
│   Private Subnets                                   │
│   ┌──────┴──────┐  ┌──────┴──────┐                 │
│   │  Private 1  │  │  Private 2  │                 │
│   │  Route → 1  │  │  Route → 1  │  ◄── All route │
│   │   AZ-a      │  │   AZ-b      │      to same   │
│   └─────────────┘  └─────────────┘      NAT       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Cost Considerations

| Mode | NAT Gateways | EIPs | Monthly Cost (approx) |
|------|--------------|------|----------------------|
| Single NAT | 1 | 1 | ~$32 + data |
| HA (2 AZ) | 2 | 2 | ~$64 + data |
| HA (3 AZ) | 3 | 3 | ~$96 + data |

Data processing: $0.045/GB

**Recommendation:**
- Development/staging: Single NAT
- Production: HA mode (one per AZ)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- NAT Gateways must be placed in public subnets with an Internet Gateway route.
- Each private route table gets a default route (0.0.0.0/0) to a NAT Gateway.
- In HA mode, route tables are mapped to NAT Gateways by index (AZ alignment).
- Elastic IPs are allocated automatically unless `reuse_existing_eips` is true.
