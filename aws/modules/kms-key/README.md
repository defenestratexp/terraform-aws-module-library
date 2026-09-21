# KMS Key Module

Creates a KMS customer managed key with configurable key policy and automatic rotation.

## Usage

### Basic Encryption Key

```hcl
module "encryption_key" {
  source = "path/to/modules/kms-key"

  alias       = "my-app/encryption"
  description = "Encryption key for my application"

  tags = {
    Environment = "production"
  }
}
```

### Key with Specific Users

```hcl
module "app_key" {
  source = "path/to/modules/kms-key"

  alias       = "my-app/data"
  description = "Data encryption key"

  key_administrators = [
    "arn:aws:iam::123456789012:role/admin-role"
  ]

  key_users = [
    "arn:aws:iam::123456789012:role/app-role",
    "arn:aws:iam::123456789012:role/lambda-role"
  ]
}
```

### Key for S3 Encryption

```hcl
module "s3_key" {
  source = "path/to/modules/kms-key"

  alias       = "s3/my-bucket"
  description = "KMS key for S3 bucket encryption"

  key_users = [
    "arn:aws:iam::123456789012:role/app-role"
  ]

  key_service_users = [
    "arn:aws:iam::123456789012:role/app-role"
  ]
}

module "bucket" {
  source = "path/to/modules/s3-bucket"

  name                 = "my-encrypted-bucket"
  encryption_algorithm = "aws:kms"
  kms_key_arn          = module.s3_key.key_arn
}
```

### Key for RDS Encryption

```hcl
module "rds_key" {
  source = "path/to/modules/kms-key"

  alias       = "rds/my-database"
  description = "KMS key for RDS encryption"

  # Allow RDS to use the key
  key_grants = ["rds.amazonaws.com"]
}
```

### Key for Secrets Manager

```hcl
module "secrets_key" {
  source = "path/to/modules/kms-key"

  alias       = "secrets/my-app"
  description = "KMS key for Secrets Manager"

  key_users = [
    "arn:aws:iam::123456789012:role/app-role"
  ]

  # Allow Secrets Manager to use the key
  key_grants = ["secretsmanager.amazonaws.com"]
}
```

### Asymmetric Key for Signing

```hcl
module "signing_key" {
  source = "path/to/modules/kms-key"

  alias                    = "signing/jwt"
  description              = "Key for JWT signing"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_2048"

  # Rotation not supported for asymmetric keys
  enable_key_rotation = false

  key_users = [
    "arn:aws:iam::123456789012:role/api-role"
  ]
}
```

### Multi-Region Key

```hcl
module "global_key" {
  source = "path/to/modules/kms-key"

  alias        = "global/my-app"
  description  = "Multi-region key for global application"
  multi_region = true

  key_users = [
    "arn:aws:iam::123456789012:role/app-role"
  ]
}
```

### Custom Key Policy

```hcl
module "custom_key" {
  source = "path/to/modules/kms-key"

  alias       = "custom/my-key"
  description = "Key with custom policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudTrail"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```

## Features

- **Symmetric and Asymmetric Keys**: Support for various key types
- **Key Policy Builder**: Flexible policy construction or custom JSON
- **Automatic Rotation**: Configurable rotation period for symmetric keys
- **Multi-Region**: Create multi-region primary keys
- **Aliases**: Friendly names for key identification

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alias | Alias for the KMS key | `string` | n/a | yes |
| description | Description of the key | `string` | `""` | no |
| key_usage | Key usage type | `string` | `"ENCRYPT_DECRYPT"` | no |
| customer_master_key_spec | Key specification | `string` | `"SYMMETRIC_DEFAULT"` | no |
| multi_region | Create multi-region key | `bool` | `false` | no |
| policy | Custom key policy JSON | `string` | `""` | no |
| enable_default_policy | Enable default root access | `bool` | `true` | no |
| key_administrators | IAM ARNs that can administer | `list(string)` | `[]` | no |
| key_users | IAM ARNs that can use for crypto | `list(string)` | `[]` | no |
| key_service_users | IAM ARNs that can grant to services | `list(string)` | `[]` | no |
| key_grants | Service principals for grants | `list(string)` | `[]` | no |
| enable_key_rotation | Enable automatic rotation | `bool` | `true` | no |
| rotation_period_in_days | Rotation period (90-2560) | `number` | `365` | no |
| deletion_window_in_days | Deletion waiting period | `number` | `30` | no |
| is_enabled | Whether the key is enabled | `bool` | `true` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key_id | The globally unique key identifier |
| key_arn | The ARN of the key |
| alias_arn | The ARN of the alias |
| alias_name | The name of the alias |
| target_key_arn | The ARN of the target key |

## Key Specifications

| Spec | Usage | Rotation |
|------|-------|----------|
| SYMMETRIC_DEFAULT | ENCRYPT_DECRYPT | Yes |
| RSA_2048 | ENCRYPT_DECRYPT, SIGN_VERIFY | No |
| RSA_3072 | ENCRYPT_DECRYPT, SIGN_VERIFY | No |
| RSA_4096 | ENCRYPT_DECRYPT, SIGN_VERIFY | No |
| ECC_NIST_P256 | SIGN_VERIFY | No |
| ECC_NIST_P384 | SIGN_VERIFY | No |
| ECC_NIST_P521 | SIGN_VERIFY | No |
| ECC_SECG_P256K1 | SIGN_VERIFY | No |
| HMAC_224 | GENERATE_VERIFY_MAC | No |
| HMAC_256 | GENERATE_VERIFY_MAC | No |
| HMAC_384 | GENERATE_VERIFY_MAC | No |
| HMAC_512 | GENERATE_VERIFY_MAC | No |
