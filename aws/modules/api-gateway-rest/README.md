# API Gateway REST API Module

Creates an AWS API Gateway REST API with stages, custom domains, and usage plans.

## Usage

### Basic REST API

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name        = "my-api"
  description = "My REST API"

  stages = {
    prod = {
      description = "Production stage"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### REST API with OpenAPI Spec

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "openapi-api"

  openapi_spec = file("${path.module}/openapi.yaml")

  stages = {
    prod = {}
  }

  tags = {
    Environment = "production"
  }
}
```

### REST API with Custom Domain

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "domain-api"

  stages = {
    prod = {}
  }

  domain_names = {
    "api.example.com" = {
      certificate_arn = module.acm_certificate.arn
      stage_name      = "prod"
    }
  }

  tags = {
    Environment = "production"
  }
}

# Create Route53 record pointing to API Gateway
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"

  alias {
    name                   = module.api_gateway.domain_names["api.example.com"].regional_domain_name
    zone_id                = module.api_gateway.domain_names["api.example.com"].regional_zone_id
    evaluate_target_health = true
  }
}
```

### REST API with Usage Plans and API Keys

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "metered-api"

  stages = {
    prod = {}
  }

  api_keys = {
    partner-a = {
      description = "Partner A API Key"
    }
    partner-b = {
      description = "Partner B API Key"
    }
  }

  usage_plans = {
    basic = {
      description = "Basic tier"
      quota_settings = {
        limit  = 1000
        period = "MONTH"
      }
      throttle_settings = {
        burst_limit = 10
        rate_limit  = 5
      }
      api_stages = [
        { stage_name = "prod" }
      ]
    }
    premium = {
      description = "Premium tier"
      quota_settings = {
        limit  = 100000
        period = "MONTH"
      }
      throttle_settings = {
        burst_limit = 100
        rate_limit  = 50
      }
      api_stages = [
        { stage_name = "prod" }
      ]
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### REST API with Access Logging

```hcl
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/my-api"
  retention_in_days = 30
}

module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "logged-api"

  stages = {
    prod = {
      access_log_settings = {
        destination_arn = aws_cloudwatch_log_group.api_logs.arn
      }
      xray_tracing_enabled = true
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### REST API with Caching

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "cached-api"

  stages = {
    prod = {
      cache_cluster_enabled = true
      cache_cluster_size    = "0.5"  # GB
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Private REST API

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "private-api"

  endpoint_type    = "PRIVATE"
  vpc_endpoint_ids = [aws_vpc_endpoint.api_gateway.id]

  resource_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "execute-api:/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.api_gateway.id
          }
        }
      }
    ]
  })

  stages = {
    prod = {}
  }

  tags = {
    Environment = "production"
  }
}
```

### REST API with Canary Deployment

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "canary-api"

  stages = {
    prod = {
      canary_settings = {
        percent_traffic = 10
        stage_variable_overrides = {
          lambda_alias = "canary"
        }
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Edge-Optimized REST API

```hcl
module "api_gateway" {
  source = "path/to/modules/api-gateway-rest"

  name = "edge-api"

  endpoint_type = "EDGE"

  stages = {
    prod = {}
  }

  domain_names = {
    "api.example.com" = {
      certificate_arn = module.acm_certificate_us_east_1.arn  # Must be in us-east-1
      endpoint_type   = "EDGE"
      stage_name      = "prod"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Endpoint Types**: REGIONAL, EDGE, or PRIVATE
- **OpenAPI Import**: Create API from OpenAPI specification
- **Custom Domains**: Map custom domains with SSL certificates
- **Stages**: Multiple deployment stages with caching
- **API Keys**: Create and manage API keys
- **Usage Plans**: Rate limiting and quotas
- **Access Logging**: CloudWatch logging for API calls
- **X-Ray Tracing**: Distributed tracing support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | API name | `string` | n/a | yes |
| description | API description | `string` | `""` | no |
| endpoint_type | EDGE, REGIONAL, PRIVATE | `string` | `"REGIONAL"` | no |
| vpc_endpoint_ids | VPC endpoints for PRIVATE | `list(string)` | `[]` | no |
| openapi_spec | OpenAPI specification | `string` | `null` | no |
| stages | Stage configurations | `map(object)` | `{}` | no |
| domain_names | Custom domain configs | `map(object)` | `{}` | no |
| api_keys | API key configurations | `map(object)` | `{}` | no |
| usage_plans | Usage plan configs | `map(object)` | `{}` | no |
| resource_policy | Resource policy JSON | `string` | `null` | no |
| binary_media_types | Binary media types | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | REST API ID |
| arn | REST API ARN |
| name | REST API name |
| root_resource_id | Root resource ID |
| execution_arn | Execution ARN for Lambda |
| stage_invoke_urls | Map of stage invoke URLs |
| invoke_url | First stage invoke URL |
| domain_names | Custom domain configurations |
| api_key_ids | Map of API key IDs |
| api_key_values | Map of API key values |
| usage_plan_ids | Map of usage plan IDs |

## Lambda Integration

To integrate with Lambda:

```hcl
# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/*"
}
```

## Considerations

- EDGE endpoints route through CloudFront (higher latency for first request)
- REGIONAL endpoints are better for same-region clients
- PRIVATE endpoints require VPC endpoint
- API caching incurs additional costs
- Custom domains require ACM certificates
