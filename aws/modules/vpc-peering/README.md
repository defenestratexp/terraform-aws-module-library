# VPC Peering Module

Creates a VPC peering connection with optional route management.

## Usage

### Same-Account, Same-Region Peering

```hcl
module "vpc_peering" {
  source = "path/to/modules/vpc-peering"

  name             = "prod-to-shared"
  requester_vpc_id = module.vpc_prod.id
  accepter_vpc_id  = module.vpc_shared.id

  # Auto-create routes
  requester_route_table_ids = module.vpc_prod.private_route_table_ids
  accepter_route_table_ids  = module.vpc_shared.private_route_table_ids
  requester_cidr_block      = module.vpc_prod.cidr_block
  accepter_cidr_block       = module.vpc_shared.cidr_block

  tags = {
    Environment = "production"
  }
}
```

### Cross-Account Peering

```hcl
# In the requester account
module "vpc_peering_requester" {
  source = "path/to/modules/vpc-peering"

  name             = "prod-to-shared-services"
  requester_vpc_id = module.vpc.id
  accepter_vpc_id  = "vpc-12345678"  # VPC in other account
  peer_owner_id    = "123456789012"   # Other account ID

  auto_accept = false  # Must be accepted in the other account

  # Routes in requester VPC
  requester_route_table_ids = module.vpc.private_route_table_ids
  accepter_cidr_block       = "10.1.0.0/16"  # CIDR of accepter VPC
}

# In the accepter account (separate Terraform state)
resource "aws_vpc_peering_connection_accepter" "main" {
  vpc_peering_connection_id = "pcx-12345678"  # ID from requester
  auto_accept               = true

  tags = {
    Name = "prod-to-shared-services"
    Side = "Accepter"
  }
}

# Routes in accepter VPC
resource "aws_route" "to_requester" {
  for_each = toset(module.vpc.private_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = "10.0.0.0/16"  # CIDR of requester VPC
  vpc_peering_connection_id = "pcx-12345678"
}
```

### Cross-Region Peering

```hcl
provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

module "vpc_peering" {
  source = "path/to/modules/vpc-peering"

  name             = "east-to-west"
  requester_vpc_id = module.vpc_east.id
  accepter_vpc_id  = module.vpc_west.id
  peer_region      = "us-west-2"

  auto_accept = false  # Cross-region requires manual acceptance

  requester_route_table_ids = module.vpc_east.private_route_table_ids
  accepter_cidr_block       = module.vpc_west.cidr_block
}

# Accept in the west region
resource "aws_vpc_peering_connection_accepter" "west" {
  provider = aws.us_west

  vpc_peering_connection_id = module.vpc_peering.id
  auto_accept               = true
}
```

### Peering with DNS Resolution

```hcl
module "vpc_peering" {
  source = "path/to/modules/vpc-peering"

  name             = "app-to-database"
  requester_vpc_id = module.vpc_app.id
  accepter_vpc_id  = module.vpc_database.id

  # Enable DNS resolution across VPCs
  allow_remote_vpc_dns_resolution = true

  requester_route_table_ids = module.vpc_app.private_route_table_ids
  accepter_route_table_ids  = module.vpc_database.private_route_table_ids
  requester_cidr_block      = module.vpc_app.cidr_block
  accepter_cidr_block       = module.vpc_database.cidr_block
}
```

### Multiple Peering Connections

```hcl
locals {
  peering_configs = {
    "prod-to-shared" = {
      requester_vpc_id          = module.vpc_prod.id
      accepter_vpc_id           = module.vpc_shared.id
      requester_route_table_ids = module.vpc_prod.private_route_table_ids
      accepter_route_table_ids  = module.vpc_shared.private_route_table_ids
      requester_cidr_block      = module.vpc_prod.cidr_block
      accepter_cidr_block       = module.vpc_shared.cidr_block
    }
    "dev-to-shared" = {
      requester_vpc_id          = module.vpc_dev.id
      accepter_vpc_id           = module.vpc_shared.id
      requester_route_table_ids = module.vpc_dev.private_route_table_ids
      accepter_route_table_ids  = module.vpc_shared.private_route_table_ids
      requester_cidr_block      = module.vpc_dev.cidr_block
      accepter_cidr_block       = module.vpc_shared.cidr_block
    }
  }
}

module "vpc_peering" {
  source   = "path/to/modules/vpc-peering"
  for_each = local.peering_configs

  name             = each.key
  requester_vpc_id = each.value.requester_vpc_id
  accepter_vpc_id  = each.value.accepter_vpc_id

  requester_route_table_ids = each.value.requester_route_table_ids
  accepter_route_table_ids  = each.value.accepter_route_table_ids
  requester_cidr_block      = each.value.requester_cidr_block
  accepter_cidr_block       = each.value.accepter_cidr_block
}
```

## Features

- **Same-Account Peering**: Auto-accept in same account/region
- **Cross-Account Peering**: Support for different AWS accounts
- **Cross-Region Peering**: Support for different AWS regions
- **DNS Resolution**: Enable private DNS across VPCs
- **Route Management**: Automatic route table updates

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the peering connection | `string` | n/a | yes |
| requester_vpc_id | ID of the requester VPC | `string` | n/a | yes |
| accepter_vpc_id | ID of the accepter VPC | `string` | n/a | yes |
| peer_owner_id | AWS account ID for cross-account | `string` | `""` | no |
| peer_region | Region for cross-region peering | `string` | `""` | no |
| auto_accept | Auto-accept the connection | `bool` | `true` | no |
| allow_remote_vpc_dns_resolution | Enable cross-VPC DNS | `bool` | `true` | no |
| requester_route_table_ids | Route tables in requester VPC | `list(string)` | `[]` | no |
| accepter_route_table_ids | Route tables in accepter VPC | `list(string)` | `[]` | no |
| requester_cidr_block | CIDR of requester VPC | `string` | `""` | no |
| accepter_cidr_block | CIDR of accepter VPC | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The peering connection ID |
| accept_status | The peering connection status |
| requester_vpc_id | The requester VPC ID |
| accepter_vpc_id | The accepter VPC ID |
| requester_cidr_block | The requester VPC CIDR |
| accepter_cidr_block | The accepter VPC CIDR |

## Limitations

- Cross-account peering requires acceptance in the target account
- Cross-region peering requires acceptance (cannot auto-accept)
- VPC CIDR blocks cannot overlap
- Maximum of 125 peering connections per VPC
- Consider Transit Gateway for complex topologies
