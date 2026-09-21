# CloudFront Module

Creates a CloudFront distribution with flexible origin and caching configurations.

## Usage

### S3 Static Website

```hcl
module "cdn" {
  source = "path/to/modules/cloudfront"

  origin = {
    domain_name              = module.s3_bucket.bucket_regional_domain_name
    origin_id                = "s3-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  default_root_object = "index.html"

  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  aliases             = ["cdn.example.com"]
  acm_certificate_arn = module.certificate.arn

  tags = {
    Environment = "production"
  }
}
```

### ALB Origin

```hcl
module "cdn" {
  source = "path/to/modules/cloudfront"

  origin = {
    domain_name = module.alb.dns_name
    origin_id   = "alb"
    custom_origin_config = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior = {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  aliases             = ["app.example.com"]
  acm_certificate_arn = module.certificate.arn
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}
```

### Multiple Origins with Path Patterns

```hcl
module "cdn" {
  source = "path/to/modules/cloudfront"

  origin = {
    domain_name              = module.s3_static.bucket_regional_domain_name
    origin_id                = "s3-static"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  additional_origins = [
    {
      domain_name = module.alb.dns_name
      origin_id   = "alb-api"
      custom_origin_config = {
        origin_protocol_policy = "https-only"
      }
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern     = "/api/*"
      target_origin_id = "alb-api"
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cache_policy_id  = data.aws_cloudfront_cache_policy.caching_disabled.id
    }
  ]

  aliases             = ["www.example.com"]
  acm_certificate_arn = module.certificate.arn
}
```

### With Lambda@Edge

```hcl
module "cdn" {
  source = "path/to/modules/cloudfront"

  origin = {
    domain_name              = module.s3_bucket.bucket_regional_domain_name
    origin_id                = "s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  default_cache_behavior = {
    lambda_function_associations = [
      {
        event_type = "viewer-request"
        lambda_arn = aws_lambda_function.auth.qualified_arn
      },
      {
        event_type = "origin-response"
        lambda_arn = aws_lambda_function.headers.qualified_arn
      }
    ]
  }

  aliases             = ["secure.example.com"]
  acm_certificate_arn = module.certificate.arn
}
```

### With Geo Restrictions

```hcl
module "cdn" {
  source = "path/to/modules/cloudfront"

  origin = {
    domain_name = "origin.example.com"
    origin_id   = "custom"
    custom_origin_config = {
      origin_protocol_policy = "https-only"
    }
  }

  geo_restriction_type      = "whitelist"
  geo_restriction_locations = ["US", "CA", "GB", "DE"]

  aliases             = ["restricted.example.com"]
  acm_certificate_arn = module.certificate.arn
}
```

### With Access Logging

```hcl
module "cdn" {
  source = "path/to/modules/cloudfront"

  origin = {
    domain_name              = module.s3_bucket.bucket_regional_domain_name
    origin_id                = "s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  logging_config = {
    bucket          = module.logs_bucket.bucket_domain_name
    prefix          = "cloudfront/"
    include_cookies = false
  }

  aliases             = ["cdn.example.com"]
  acm_certificate_arn = module.certificate.arn
}
```

## Features

- **Multiple Origins**: S3, ALB, custom HTTP origins
- **Cache Behaviors**: Default and path-pattern specific
- **Cache Policies**: Modern managed policies or legacy TTL settings
- **Edge Functions**: CloudFront Functions and Lambda@Edge
- **SSL/TLS**: Custom certificates with configurable protocols
- **Geo Restrictions**: Whitelist or blacklist by country
- **Access Logging**: S3 bucket logging
- **Origin Shield**: Regional caching layer

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| origin | Primary origin configuration | `object` | n/a | yes |
| additional_origins | Additional origin configurations | `list(object)` | `[]` | no |
| default_cache_behavior | Default cache behavior settings | `object` | `{}` | no |
| ordered_cache_behaviors | Path-specific cache behaviors | `list(object)` | `[]` | no |
| aliases | Alternate domain names (CNAMEs) | `list(string)` | `[]` | no |
| acm_certificate_arn | ACM certificate ARN (us-east-1) | `string` | `""` | no |
| minimum_protocol_version | Minimum TLS version | `string` | `"TLSv1.2_2021"` | no |
| enabled | Enable the distribution | `bool` | `true` | no |
| default_root_object | Default root object | `string` | `""` | no |
| price_class | Price class | `string` | `"PriceClass_100"` | no |
| http_version | HTTP version | `string` | `"http2and3"` | no |
| web_acl_id | WAF Web ACL ID | `string` | `""` | no |
| custom_error_responses | Custom error responses | `list(object)` | `[]` | no |
| geo_restriction_type | Geo restriction type | `string` | `"none"` | no |
| geo_restriction_locations | Country codes for geo restriction | `list(string)` | `[]` | no |
| logging_config | Access logging configuration | `object` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The distribution ID |
| arn | The ARN of the distribution |
| domain_name | The CloudFront domain name |
| hosted_zone_id | The Route53 zone ID for alias records |
| status | The distribution status |
| etag | The distribution etag |

## Price Classes

| Class | Coverage |
|-------|----------|
| PriceClass_100 | US, Canada, Europe, Israel |
| PriceClass_200 | + Asia, Middle East, Africa |
| PriceClass_All | All edge locations |

## Managed Cache Policies

| Policy | Use Case |
|--------|----------|
| CachingDisabled | Dynamic content (APIs) |
| CachingOptimized | Static content |
| CachingOptimizedForUncompressedObjects | Large uncompressed files |
