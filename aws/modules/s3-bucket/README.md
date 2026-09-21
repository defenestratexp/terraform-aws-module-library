# S3 Bucket Module

Creates an S3 bucket with encryption, versioning, lifecycle policies, and optional features like CORS, logging, and static website hosting.

## Usage

### Basic Bucket

```hcl
module "bucket" {
  source = "path/to/modules/s3-bucket"

  name = "my-application-data"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Bucket with Versioning and Lifecycle Rules

```hcl
module "bucket" {
  source = "path/to/modules/s3-bucket"

  name              = "my-versioned-bucket"
  enable_versioning = true

  lifecycle_rules = [
    {
      id              = "archive-old-versions"
      enabled         = true
      expiration_days = 365

      noncurrent_version_expiration_days = 90

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_transition = [
        {
          noncurrent_days = 30
          storage_class   = "GLACIER"
        }
      ]
    }
  ]
}
```

### Bucket with KMS Encryption

```hcl
module "bucket" {
  source = "path/to/modules/s3-bucket"

  name                 = "my-encrypted-bucket"
  encryption_algorithm = "aws:kms"
  kms_key_arn          = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  bucket_key_enabled   = true
}
```

### Static Website Hosting

```hcl
module "website" {
  source = "path/to/modules/s3-bucket"

  name               = "my-static-website"
  block_public_access = false
  enable_website     = true

  website_index_document = "index.html"
  website_error_document = "404.html"

  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3600
    }
  ]
}
```

### Bucket with Access Logging

```hcl
module "logs_bucket" {
  source = "path/to/modules/s3-bucket"

  name = "my-access-logs"
}

module "bucket" {
  source = "path/to/modules/s3-bucket"

  name                  = "my-logged-bucket"
  enable_logging        = true
  logging_target_bucket = module.logs_bucket.id
  logging_target_prefix = "access-logs/"
}
```

## Features

- **Encryption**: Server-side encryption with AES256 or AWS KMS
- **Versioning**: Optional object versioning
- **Lifecycle Rules**: Flexible lifecycle policies with transitions and expirations
- **Public Access Block**: Configurable public access controls (blocked by default)
- **CORS**: Cross-origin resource sharing configuration
- **Website Hosting**: Static website configuration
- **Access Logging**: Server access logging to another bucket
- **Ownership Controls**: Object ownership settings

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the S3 bucket (must be globally unique) | `string` | n/a | yes |
| enable_encryption | Enable server-side encryption | `bool` | `true` | no |
| encryption_algorithm | Encryption algorithm (AES256 or aws:kms) | `string` | `"AES256"` | no |
| kms_key_arn | KMS key ARN for encryption | `string` | `""` | no |
| bucket_key_enabled | Enable S3 Bucket Key for KMS encryption | `bool` | `true` | no |
| enable_versioning | Enable versioning on the bucket | `bool` | `false` | no |
| lifecycle_rules | List of lifecycle rules | `list(object)` | `[]` | no |
| block_public_access | Block all public access to the bucket | `bool` | `true` | no |
| force_destroy | Allow deletion of non-empty bucket | `bool` | `false` | no |
| object_ownership | Object ownership setting | `string` | `"BucketOwnerEnforced"` | no |
| enable_logging | Enable access logging | `bool` | `false` | no |
| logging_target_bucket | Target bucket for access logs | `string` | `""` | no |
| logging_target_prefix | Prefix for access logs | `string` | `""` | no |
| cors_rules | List of CORS rules | `list(object)` | `[]` | no |
| enable_website | Enable static website hosting | `bool` | `false` | no |
| website_index_document | Index document for website | `string` | `"index.html"` | no |
| website_error_document | Error document for website | `string` | `"error.html"` | no |
| tags | Additional tags to apply to the bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The name of the bucket |
| arn | The ARN of the bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The bucket region-specific domain name |
| hosted_zone_id | The Route 53 Hosted Zone ID for this bucket's region |
| region | The AWS region this bucket resides in |
| website_endpoint | The website endpoint (if website hosting is enabled) |
| website_domain | The domain of the website endpoint (if website hosting is enabled) |
