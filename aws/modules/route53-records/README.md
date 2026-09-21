# Route53 Records Module

Creates Route53 DNS records with support for various record types and routing policies.

## Usage

### Simple A Records

```hcl
module "dns_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    web = {
      name    = "www"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.1"]
    }

    mail = {
      name    = "mail"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.2"]
    }
  }
}
```

### Alias Records (ALB, CloudFront, etc.)

```hcl
module "dns_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    app = {
      name = "app"
      type = "A"
      alias = {
        name    = module.alb.dns_name
        zone_id = module.alb.zone_id
      }
    }

    cdn = {
      name = "cdn"
      type = "A"
      alias = {
        name                   = module.cloudfront.domain_name
        zone_id                = module.cloudfront.hosted_zone_id
        evaluate_target_health = false
      }
    }
  }
}
```

### MX and TXT Records

```hcl
module "email_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    mx = {
      name = ""  # apex domain
      type = "MX"
      ttl  = 3600
      records = [
        "10 mail1.example.com",
        "20 mail2.example.com"
      ]
    }

    spf = {
      name    = ""
      type    = "TXT"
      ttl     = 300
      records = ["v=spf1 include:_spf.google.com ~all"]
    }

    dkim = {
      name    = "google._domainkey"
      type    = "TXT"
      ttl     = 300
      records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSq..."]
    }
  }
}
```

### Weighted Routing

```hcl
module "weighted_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    api-blue = {
      name           = "api"
      type           = "A"
      ttl            = 60
      records        = ["192.0.2.1"]
      routing_policy = "weighted"
      weight         = 70
      set_identifier = "blue"
    }

    api-green = {
      name           = "api"
      type           = "A"
      ttl            = 60
      records        = ["192.0.2.2"]
      routing_policy = "weighted"
      weight         = 30
      set_identifier = "green"
    }
  }
}
```

### Latency-Based Routing

```hcl
module "latency_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    api-east = {
      name           = "api"
      type           = "A"
      routing_policy = "latency"
      latency_region = "us-east-1"
      set_identifier = "us-east-1"
      alias = {
        name    = module.alb_east.dns_name
        zone_id = module.alb_east.zone_id
      }
    }

    api-west = {
      name           = "api"
      type           = "A"
      routing_policy = "latency"
      latency_region = "us-west-2"
      set_identifier = "us-west-2"
      alias = {
        name    = module.alb_west.dns_name
        zone_id = module.alb_west.zone_id
      }
    }
  }
}
```

### Geolocation Routing

```hcl
module "geo_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    www-eu = {
      name           = "www"
      type           = "A"
      ttl            = 300
      records        = ["192.0.2.1"]
      routing_policy = "geolocation"
      set_identifier = "eu"
      geolocation = {
        continent = "EU"
      }
    }

    www-us = {
      name           = "www"
      type           = "A"
      ttl            = 300
      records        = ["192.0.2.2"]
      routing_policy = "geolocation"
      set_identifier = "us"
      geolocation = {
        country = "US"
      }
    }

    www-default = {
      name           = "www"
      type           = "A"
      ttl            = 300
      records        = ["192.0.2.3"]
      routing_policy = "geolocation"
      set_identifier = "default"
      geolocation = {
        country = "*"  # Default/catch-all
      }
    }
  }
}
```

### Failover Routing

```hcl
module "failover_records" {
  source = "path/to/modules/route53-records"

  zone_id = module.zone.zone_id

  records = {
    www-primary = {
      name            = "www"
      type            = "A"
      ttl             = 60
      records         = ["192.0.2.1"]
      routing_policy  = "failover"
      failover_type   = "PRIMARY"
      set_identifier  = "primary"
      health_check_id = aws_route53_health_check.primary.id
    }

    www-secondary = {
      name           = "www"
      type           = "A"
      ttl            = 60
      records        = ["192.0.2.2"]
      routing_policy = "failover"
      failover_type  = "SECONDARY"
      set_identifier = "secondary"
    }
  }
}
```

## Features

- **Multiple Record Types**: A, AAAA, CNAME, MX, TXT, NS, PTR, SRV, CAA
- **Alias Records**: Native AWS resource integration
- **Routing Policies**: Simple, weighted, latency, geolocation, failover, multivalue
- **Health Checks**: Integration with Route53 health checks
- **Batch Creation**: Create multiple records efficiently

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| zone_id | Route53 hosted zone ID | `string` | n/a | yes |
| records | Map of DNS records to create | `map(object)` | `{}` | no |

### Record Object

| Field | Description | Required |
|-------|-------------|----------|
| name | Record name (subdomain) | Yes |
| type | Record type (A, AAAA, CNAME, etc.) | Yes |
| ttl | TTL in seconds | No (default: 300) |
| records | List of record values | No (required if not alias) |
| alias | Alias target configuration | No |
| routing_policy | Routing policy type | No (default: simple) |
| set_identifier | Unique identifier for routing policies | Conditional |
| health_check_id | Health check ID | No |
| weight | Weight for weighted routing | Conditional |
| latency_region | Region for latency routing | Conditional |
| geolocation | Geolocation settings | Conditional |
| failover_type | PRIMARY or SECONDARY | Conditional |

## Outputs

| Name | Description |
|------|-------------|
| records | Map of created DNS records with details |
| fqdns | Map of record keys to FQDNs |

## Record Types

| Type | Description |
|------|-------------|
| A | IPv4 address |
| AAAA | IPv6 address |
| CNAME | Canonical name (alias to another domain) |
| MX | Mail exchange |
| TXT | Text record |
| NS | Name server |
| PTR | Pointer (reverse DNS) |
| SRV | Service locator |
| CAA | Certificate Authority Authorization |
