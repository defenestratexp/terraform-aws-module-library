# Transit Gateway Attachment Module

Attaches a VPC to an AWS Transit Gateway with route management.

## Usage

### Basic VPC Attachment

```hcl
module "tgw_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "prod-vpc-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.private_subnet_ids

  tags = {
    Environment = "production"
  }
}
```

### Attachment with VPC Routes

```hcl
module "tgw_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "prod-vpc-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.private_subnet_ids

  # Add routes in VPC pointing to TGW
  vpc_route_table_ids = module.vpc.private_route_table_ids
  destination_cidr_blocks = [
    "10.1.0.0/16",  # Route to shared services VPC
    "10.2.0.0/16",  # Route to dev VPC
    "192.168.0.0/16",  # Route to on-premises
  ]

  tags = {
    Environment = "production"
  }
}
```

### Attachment with Custom Route Table

```hcl
module "tgw_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "prod-vpc-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.private_subnet_ids

  # Associate with specific TGW route table
  transit_gateway_route_table_id = module.transit_gateway.route_table_ids["production"]

  # Propagate routes to multiple route tables
  transit_gateway_route_table_propagation_ids = [
    module.transit_gateway.route_table_ids["production"],
    module.transit_gateway.route_table_ids["shared-services"],
  ]

  tags = {
    Environment = "production"
  }
}
```

### Attachment with Appliance Mode

```hcl
# Use appliance mode for stateful network appliances (firewalls, IDS)
module "tgw_attachment_firewall" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "firewall-vpc-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.firewall_vpc.id
  subnet_ids         = module.firewall_vpc.private_subnet_ids

  # Enable appliance mode for symmetric routing
  appliance_mode_support = "enable"

  tags = {
    Environment = "security"
    Purpose     = "network-firewall"
  }
}
```

### IPv6-Enabled Attachment

```hcl
module "tgw_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "dual-stack-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.private_subnet_ids

  # Enable IPv6
  ipv6_support = "enable"

  tags = {
    Environment = "production"
  }
}
```

### Hub and Spoke Pattern

```hcl
# Hub VPC (shared services)
module "hub_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "hub-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.hub_vpc.id
  subnet_ids         = module.hub_vpc.private_subnet_ids

  transit_gateway_route_table_id = module.transit_gateway.route_table_ids["shared-services"]

  # Propagate hub routes to all route tables
  transit_gateway_route_table_propagation_ids = [
    module.transit_gateway.route_table_ids["production"],
    module.transit_gateway.route_table_ids["development"],
    module.transit_gateway.route_table_ids["shared-services"],
  ]

  # Routes from hub to all spokes
  vpc_route_table_ids = module.hub_vpc.private_route_table_ids
  destination_cidr_blocks = [
    "10.1.0.0/16",  # Production VPC
    "10.2.0.0/16",  # Development VPC
  ]
}

# Spoke VPC (production)
module "prod_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "prod-attachment"
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.prod_vpc.id
  subnet_ids         = module.prod_vpc.private_subnet_ids

  transit_gateway_route_table_id = module.transit_gateway.route_table_ids["production"]

  # Only propagate to shared-services (not other spokes)
  transit_gateway_route_table_propagation_ids = [
    module.transit_gateway.route_table_ids["shared-services"],
  ]

  # Routes to hub only
  vpc_route_table_ids     = module.prod_vpc.private_route_table_ids
  destination_cidr_blocks = ["10.0.0.0/16"]  # Hub VPC CIDR
}
```

### Cross-Account Attachment

```hcl
# In the spoke account (TGW shared via RAM)
data "aws_ec2_transit_gateway" "shared" {
  filter {
    name   = "owner-id"
    values = ["111111111111"]  # Hub account ID
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

module "tgw_attachment" {
  source = "path/to/modules/transit-gateway-attachment"

  name               = "spoke-vpc-attachment"
  transit_gateway_id = data.aws_ec2_transit_gateway.shared.id
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.private_subnet_ids

  # Routes to other VPCs via TGW
  vpc_route_table_ids = module.vpc.private_route_table_ids
  destination_cidr_blocks = [
    "10.0.0.0/8",  # All internal networks
  ]

  tags = {
    Environment = "production"
    Account     = "spoke-account"
  }
}
```

## Features

- **VPC Attachment**: Attach VPCs to Transit Gateway
- **Route Table Association**: Associate with specific TGW route tables
- **Route Propagation**: Propagate routes to multiple route tables
- **VPC Routes**: Automatically create routes in VPC route tables
- **Appliance Mode**: Support for stateful network appliances
- **IPv6 Support**: Dual-stack networking support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the attachment | `string` | n/a | yes |
| transit_gateway_id | ID of the Transit Gateway | `string` | n/a | yes |
| vpc_id | ID of the VPC to attach | `string` | n/a | yes |
| subnet_ids | Subnet IDs for the attachment | `list(string)` | n/a | yes |
| dns_support | Enable DNS support | `string` | `"enable"` | no |
| ipv6_support | Enable IPv6 support | `string` | `"disable"` | no |
| appliance_mode_support | Enable appliance mode | `string` | `"disable"` | no |
| transit_gateway_route_table_id | TGW route table to associate with | `string` | `""` | no |
| transit_gateway_route_table_propagation_ids | TGW route tables for propagation | `list(string)` | `[]` | no |
| vpc_route_table_ids | VPC route tables for TGW routes | `list(string)` | `[]` | no |
| destination_cidr_blocks | Destination CIDRs for VPC routes | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The attachment ID |
| vpc_owner_id | The AWS account ID of the VPC owner |
| transit_gateway_id | The Transit Gateway ID |
| vpc_id | The attached VPC ID |
| subnet_ids | The subnet IDs used |
| route_table_association_id | The TGW route table association ID |
| route_table_propagation_ids | Map of TGW route table propagation IDs |
| vpc_route_ids | List of VPC route IDs created |

## Subnet Selection

- Use one subnet per Availability Zone
- Use private subnets (transit traffic shouldn't traverse public subnets)
- Ensure subnets have sufficient IP addresses
- TGW creates an ENI in each subnet

## Considerations

- Each attachment incurs hourly charges
- Data transfer charges apply for traffic through the attachment
- Appliance mode ensures symmetric routing for stateful appliances
- Cross-account attachments require TGW sharing via RAM
- Cross-account attachments may require acceptance in the TGW account
