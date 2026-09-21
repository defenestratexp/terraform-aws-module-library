# Transit Gateway Module

Creates an AWS Transit Gateway - a central hub for connecting VPCs and on-premises networks.

## Usage

### Basic Transit Gateway

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name        = "main-tgw"
  description = "Central transit gateway for VPC connectivity"

  tags = {
    Environment = "production"
  }
}
```

### Transit Gateway with Custom Route Tables

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "hub-tgw"

  # Disable automatic route table association/propagation for manual control
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  # Create custom route tables for segmentation
  route_tables = {
    production = {
      name = "production-rt"
      tags = { Environment = "production" }
    }
    development = {
      name = "development-rt"
      tags = { Environment = "development" }
    }
    shared-services = {
      name = "shared-services-rt"
    }
  }

  tags = {
    Environment = "shared"
  }
}
```

### Transit Gateway with Cross-Account Sharing

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "shared-tgw"

  # Auto-accept attachments from shared accounts
  auto_accept_shared_attachments = "enable"

  # Share via RAM
  share_transit_gateway = true
  ram_share_name        = "transit-gateway-share"
  ram_principals = [
    "123456789012",  # Account ID
    "234567890123",  # Another account
  ]

  tags = {
    Environment = "shared"
  }
}
```

### Transit Gateway with Organization Sharing

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "org-tgw"

  auto_accept_shared_attachments = "enable"

  # Share with entire organization
  share_transit_gateway         = true
  ram_allow_external_principals = false
  ram_principals = [
    "arn:aws:organizations::111111111111:organization/o-exampleorgid"
  ]

  tags = {
    Environment = "shared"
  }
}
```

### Transit Gateway with Custom ASN

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "custom-tgw"

  # Use custom ASN for BGP routing (useful for VPN/Direct Connect)
  amazon_side_asn = 65000

  # Enable ECMP for VPN load balancing
  vpn_ecmp_support = "enable"

  tags = {
    Environment = "production"
  }
}
```

### Transit Gateway with Multicast

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "multicast-tgw"

  # Enable multicast support
  multicast_support = "enable"

  tags = {
    Environment = "production"
  }
}
```

### Transit Gateway with Connect CIDR

```hcl
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "connect-tgw"

  # CIDR blocks for Transit Gateway Connect attachments
  transit_gateway_cidr_blocks = ["10.100.0.0/24"]

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Central Hub**: Connect multiple VPCs and on-premises networks
- **Custom Route Tables**: Segment traffic with separate route tables
- **Cross-Account Sharing**: Share via RAM with other accounts or organization
- **VPN ECMP**: Load balance across multiple VPN connections
- **Multicast Support**: Enable multicast routing between VPCs
- **Custom ASN**: Use custom BGP ASN for routing integration

## Network Segmentation Pattern

```hcl
# Create TGW with custom route tables for segmentation
module "transit_gateway" {
  source = "path/to/modules/transit-gateway"

  name = "segmented-tgw"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  route_tables = {
    production = {}
    non-production = {}
    shared-services = {}
  }
}

# Use transit-gateway-attachment module to attach VPCs
# and configure route associations/propagations
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Transit Gateway | `string` | n/a | yes |
| description | Description of the Transit Gateway | `string` | `""` | no |
| amazon_side_asn | Private ASN (64512-65534 or 4200000000-4294967294) | `number` | `64512` | no |
| auto_accept_shared_attachments | Auto-accept attachments | `string` | `"disable"` | no |
| default_route_table_association | Auto-associate with default RT | `string` | `"enable"` | no |
| default_route_table_propagation | Auto-propagate to default RT | `string` | `"enable"` | no |
| dns_support | Enable DNS support | `string` | `"enable"` | no |
| multicast_support | Enable multicast | `string` | `"disable"` | no |
| vpn_ecmp_support | Enable VPN ECMP | `string` | `"enable"` | no |
| transit_gateway_cidr_blocks | CIDR blocks for Connect attachments | `list(string)` | `[]` | no |
| route_tables | Map of route tables to create | `map(object)` | `{}` | no |
| share_transit_gateway | Share via RAM | `bool` | `false` | no |
| ram_share_name | RAM share name | `string` | `""` | no |
| ram_principals | List of principals to share with | `list(string)` | `[]` | no |
| ram_allow_external_principals | Allow external principals | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The Transit Gateway ID |
| arn | The Transit Gateway ARN |
| owner_id | The AWS account ID of the owner |
| association_default_route_table_id | Default association route table ID |
| propagation_default_route_table_id | Default propagation route table ID |
| amazon_side_asn | The private ASN |
| route_table_ids | Map of route table names to IDs |
| route_table_arns | Map of route table names to ARNs |
| ram_resource_share_id | RAM share ID (if sharing enabled) |
| ram_resource_share_arn | RAM share ARN (if sharing enabled) |

## Architecture Patterns

### Hub and Spoke
- Central TGW in shared services account
- VPCs attach as spokes
- Shared services VPC accessible from all spokes
- Spokes isolated from each other (via route tables)

### Full Mesh
- Default route table association and propagation enabled
- All attached VPCs can communicate with each other

### Segmented Networks
- Separate route tables for different security zones
- Production, Development, Shared Services segments
- Controlled propagation between segments

## Considerations

- Transit Gateway has hourly charges plus data processing fees
- Each attachment incurs additional hourly charges
- Consider peering for simple 2-VPC connectivity
- Maximum 5,000 attachments per TGW
- Maximum 20 route tables per TGW
- Use with transit-gateway-attachment module for VPC attachments
