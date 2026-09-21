# API Gateway HTTP API Module

Creates an AWS API Gateway HTTP API (v2) with routes, stages, and custom domains.

## Usage

### Basic HTTP API with Lambda

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "my-http-api"

  routes = {
    "GET /items" = {
      integration_uri = module.list_items_lambda.invoke_arn
    }
    "POST /items" = {
      integration_uri = module.create_item_lambda.invoke_arn
    }
    "GET /items/{id}" = {
      integration_uri = module.get_item_lambda.invoke_arn
    }
  }

  tags = {
    Environment = "production"
  }
}

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api" {
  for_each = toset(["list_items", "create_item", "get_item"])

  statement_id  = "AllowHTTPAPI"
  action        = "lambda:InvokeFunction"
  function_name = module["${each.value}_lambda"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.http_api.execution_arn}/*/*"
}
```

### HTTP API with CORS

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "cors-api"

  cors_configuration = {
    allow_origins     = ["https://example.com", "https://app.example.com"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_headers     = ["Content-Type", "Authorization", "X-Request-Id"]
    expose_headers    = ["X-Request-Id"]
    max_age           = 3600
    allow_credentials = true
  }

  routes = {
    "GET /api/data" = {
      integration_uri = module.lambda.invoke_arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP API with JWT Authorizer

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "jwt-api"

  authorizers = {
    cognito = {
      authorizer_type = "JWT"
      jwt_configuration = {
        audience = [aws_cognito_user_pool_client.main.id]
        issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.main.id}"
      }
    }
  }

  routes = {
    "GET /public" = {
      integration_uri = module.public_lambda.invoke_arn
    }
    "GET /private" = {
      integration_uri    = module.private_lambda.invoke_arn
      authorization_type = "JWT"
      authorizer_id      = "cognito"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP API with Lambda Authorizer

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "lambda-auth-api"

  authorizers = {
    custom = {
      authorizer_type                   = "REQUEST"
      authorizer_uri                    = module.authorizer_lambda.invoke_arn
      authorizer_payload_format_version = "2.0"
      enable_simple_responses           = true
      authorizer_result_ttl_in_seconds  = 300
      identity_sources                  = ["$request.header.Authorization"]
    }
  }

  routes = {
    "GET /protected" = {
      integration_uri    = module.protected_lambda.invoke_arn
      authorization_type = "CUSTOM"
      authorizer_id      = "custom"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP API with Custom Domain

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "domain-api"

  routes = {
    "ANY /{proxy+}" = {
      integration_uri = module.lambda.invoke_arn
    }
  }

  domain_names = {
    "api.example.com" = {
      certificate_arn = module.acm_certificate.arn
      api_mappings = [
        {
          stage_name = "$default"
        }
      ]
    }
  }

  tags = {
    Environment = "production"
  }
}

# Create Route53 record
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"

  alias {
    name                   = module.http_api.domain_names["api.example.com"].domain_name_configuration[0].target_domain_name
    zone_id                = module.http_api.domain_names["api.example.com"].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
```

### HTTP API with Access Logging

```hcl
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/my-api"
  retention_in_days = 30
}

module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "logged-api"

  routes = {
    "GET /data" = {
      integration_uri = module.lambda.invoke_arn
    }
  }

  stages = {
    "$default" = {
      auto_deploy = true
      access_log_settings = {
        destination_arn = aws_cloudwatch_log_group.api_logs.arn
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP API with Throttling

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "throttled-api"

  routes = {
    "GET /data" = {
      integration_uri = module.lambda.invoke_arn
    }
  }

  stages = {
    "$default" = {
      auto_deploy = true
      default_route_settings = {
        throttling_burst_limit = 100
        throttling_rate_limit  = 50
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP API with VPC Link (Private Integration)

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "private-api"

  vpc_links = {
    main = {
      subnet_ids         = module.vpc.private_subnet_ids
      security_group_ids = [module.vpc_link_sg.id]
    }
  }

  routes = {
    "GET /internal" = {
      integration_type = "HTTP_PROXY"
      integration_uri  = "http://${module.alb.dns_name}/api"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP API with Multiple Stages

```hcl
module "http_api" {
  source = "path/to/modules/api-gateway-http"

  name = "multi-stage-api"

  routes = {
    "GET /data" = {
      integration_uri = module.lambda.invoke_arn
    }
  }

  stages = {
    "$default" = {
      auto_deploy = true
      stage_variables = {
        env = "dev"
      }
    }
    staging = {
      auto_deploy = false
      stage_variables = {
        env = "staging"
      }
    }
    prod = {
      auto_deploy = false
      stage_variables = {
        env = "prod"
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Low Latency**: Faster than REST API for simple use cases
- **Lower Cost**: ~70% cheaper than REST API
- **CORS Built-in**: Native CORS support
- **JWT Auth**: Built-in JWT authorizer for Cognito/OIDC
- **Lambda Authorizers**: Custom authorization logic
- **Auto Deploy**: Automatic deployment on changes
- **VPC Links**: Private integrations with VPC resources

## REST API vs HTTP API

| Feature | HTTP API | REST API |
|---------|----------|----------|
| Cost | Lower | Higher |
| Latency | Lower | Higher |
| JWT Auth | Built-in | Via Lambda |
| Usage Plans | No | Yes |
| API Keys | No | Yes |
| Caching | No | Yes |
| Request Validation | No | Yes |
| WAF Integration | No | Yes |

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
| protocol_type | HTTP or WEBSOCKET | `string` | `"HTTP"` | no |
| cors_configuration | CORS configuration | `object` | `null` | no |
| routes | Route configurations | `map(object)` | `{}` | no |
| authorizers | Authorizer configurations | `map(object)` | `{}` | no |
| stages | Stage configurations | `map(object)` | `{"$default"={}}` | no |
| domain_names | Custom domain configs | `map(object)` | `{}` | no |
| vpc_links | VPC link configurations | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | HTTP API ID |
| arn | HTTP API ARN |
| api_endpoint | Default endpoint URL |
| execution_arn | Execution ARN for Lambda |
| stage_invoke_urls | Map of stage invoke URLs |
| invoke_url | Default stage invoke URL |
| route_ids | Map of route IDs |
| authorizer_ids | Map of authorizer IDs |
| domain_names | Custom domain configurations |

## Considerations

- HTTP API doesn't support API keys or usage plans
- Use REST API if you need caching or WAF
- JWT authorizer is simpler than Lambda authorizer
- Auto deploy simplifies CI/CD but reduces control
- VPC links required for private integrations
