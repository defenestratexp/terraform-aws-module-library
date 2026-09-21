# VPN Gateway Module

Creates an AWS Virtual Private Gateway (VGW) with optional Site-to-Site VPN connection.

## Usage

### Basic VPN Gateway

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  # Enable route propagation to private route tables
  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway with Site-to-Site VPN (BGP)

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  # Custom ASN for BGP
  amazon_side_asn = 65000

  # Create customer gateway for on-premises router
  create_customer_gateway     = true
  customer_gateway_ip_address = "203.0.113.10"  # On-prem public IP
  customer_gateway_bgp_asn    = 65001

  # Create VPN connection with BGP
  create_vpn_connection = true

  # Propagate routes from VPN
  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway with Static Routing

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  # Create customer gateway
  create_customer_gateway     = true
  customer_gateway_ip_address = "203.0.113.10"
  customer_gateway_bgp_asn    = 65001  # Still required but not used

  # Create VPN connection with static routes
  create_vpn_connection             = true
  vpn_connection_static_routes_only = true
  vpn_connection_static_routes = [
    "192.168.0.0/16",  # On-premises network
    "172.16.0.0/12",   # Additional on-prem network
  ]

  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway with Custom Tunnel Configuration

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  create_customer_gateway     = true
  customer_gateway_ip_address = "203.0.113.10"
  customer_gateway_bgp_asn    = 65001

  create_vpn_connection = true

  # Custom tunnel configuration
  vpn_connection_tunnel1_inside_cidr = "169.254.10.0/30"
  vpn_connection_tunnel2_inside_cidr = "169.254.11.0/30"

  # Custom pre-shared keys (generated if not specified)
  vpn_connection_tunnel1_preshared_key = "YourPreSharedKey1"
  vpn_connection_tunnel2_preshared_key = "YourPreSharedKey2"

  # IKE settings
  vpn_connection_tunnel1_ike_versions = ["ikev2"]
  vpn_connection_tunnel2_ike_versions = ["ikev2"]

  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway with Accelerated VPN

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  create_customer_gateway     = true
  customer_gateway_ip_address = "203.0.113.10"
  customer_gateway_bgp_asn    = 65001

  create_vpn_connection = true

  # Enable Global Accelerator for VPN

  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway with Tunnel Logging

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  create_customer_gateway     = true
  customer_gateway_ip_address = "203.0.113.10"
  customer_gateway_bgp_asn    = 65001

  create_vpn_connection = true

  # Enable tunnel logging
  enable_tunnel_logging     = true
  tunnel_log_group_name     = "/vpn/prod-tunnel-logs"
  tunnel_log_retention_days = 90

  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway with Certificate-Based Authentication

```hcl
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  create_customer_gateway          = true
  customer_gateway_ip_address      = "203.0.113.10"
  customer_gateway_bgp_asn         = 65001
  customer_gateway_certificate_arn = aws_acm_certificate.vpn_cert.arn
  customer_gateway_device_name     = "cisco-router-01"

  create_vpn_connection = true

  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}
```

### VPN Gateway Only (External VPN)

```hcl
# Create VPN gateway attached to VPC
module "vpn_gateway" {
  source = "path/to/modules/vpn-gateway"

  name   = "prod-vpn-gw"
  vpc_id = module.vpc.id

  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Environment = "production"
  }
}

# Create customer gateway and VPN connection separately
# (useful for multiple VPN connections to the same VGW)
resource "aws_customer_gateway" "secondary" {
  bgp_asn    = 65002
  ip_address = "203.0.113.20"
  type       = "ipsec.1"

  tags = {
    Name = "secondary-cgw"
  }
}

resource "aws_vpn_connection" "secondary" {
  vpn_gateway_id      = module.vpn_gateway.vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.secondary.id
  type                = "ipsec.1"

  tags = {
    Name = "secondary-vpn"
  }
}
```

## Features

- **Virtual Private Gateway**: VPN endpoint in your VPC
- **Customer Gateway**: Represents on-premises VPN device
- **Site-to-Site VPN**: IPsec VPN tunnels (BGP or static routing)
- **Accelerated VPN**: Global Accelerator integration
- **Tunnel Logging**: CloudWatch logging for troubleshooting
- **Route Propagation**: Automatic route table updates

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the VPN Gateway | `string` | n/a | yes |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| amazon_side_asn | ASN for Amazon side | `number` | `null` | no |
| availability_zone | AZ for single-AZ deployment | `string` | `null` | no |
| create_customer_gateway | Create a Customer Gateway | `bool` | `false` | no |
| customer_gateway_bgp_asn | BGP ASN for customer gateway | `number` | `65000` | no |
| customer_gateway_ip_address | Public IP of customer gateway | `string` | `""` | no |
| customer_gateway_type | Customer gateway type | `string` | `"ipsec.1"` | no |
| customer_gateway_certificate_arn | Certificate ARN | `string` | `null` | no |
| customer_gateway_device_name | Device name | `string` | `""` | no |
| create_vpn_connection | Create VPN connection | `bool` | `false` | no |
| vpn_connection_type | VPN connection type | `string` | `"ipsec.1"` | no |
| vpn_connection_static_routes_only | Use static routes only | `bool` | `false` | no |
| vpn_connection_static_routes | Static route CIDRs | `list(string)` | `[]` | no |
| route_table_ids | Route tables for propagation | `list(string)` | `[]` | no |
| enable_tunnel_logging | Enable tunnel logging | `bool` | `false` | no |
| tunnel_log_group_name | Log group name | `string` | `""` | no |
| tunnel_log_retention_days | Log retention days | `number` | `30` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpn_gateway_id | The VPN Gateway ID |
| vpn_gateway_arn | The VPN Gateway ARN |
| vpn_gateway_amazon_side_asn | The Amazon side ASN |
| customer_gateway_id | The Customer Gateway ID |
| customer_gateway_arn | The Customer Gateway ARN |
| vpn_connection_id | The VPN connection ID |
| vpn_connection_arn | The VPN connection ARN |
| vpn_connection_tunnel1_address | Tunnel 1 public IP |
| vpn_connection_tunnel2_address | Tunnel 2 public IP |
| vpn_connection_tunnel1_bgp_asn | Tunnel 1 BGP ASN |
| vpn_connection_tunnel2_bgp_asn | Tunnel 2 BGP ASN |
| vpn_connection_customer_gateway_configuration | XML config for device |
| tunnel_log_group_name | CloudWatch log group name |
| tunnel_log_group_arn | CloudWatch log group ARN |

## Routing Options

### BGP (Dynamic Routing)
- Routes exchanged via BGP
- Automatic failover
- Recommended for production

### Static Routing
- Manually configure route CIDRs
- Simpler setup
- No automatic failover

## High Availability

- Two tunnels per VPN connection (active/standby)
- Use BGP for automatic failover
- Consider redundant customer gateways
- AWS SLA: 99.95% availability

## Considerations

- VPN Gateway hourly charges apply
- Data transfer charges for VPN traffic
- Maximum 10 VPN connections per VGW
- Consider Transit Gateway for multiple sites
- Use Accelerated VPN for better performance over long distances
