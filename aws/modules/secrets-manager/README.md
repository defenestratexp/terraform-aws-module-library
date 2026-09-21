# Secrets Manager Module

Creates a Secrets Manager secret with optional rotation, replication, and resource policies.

## Usage

### Basic Secret

```hcl
module "api_key" {
  source = "path/to/modules/secrets-manager"

  name          = "my-app/api-key"
  secret_string = var.api_key

  tags = {
    Environment = "production"
  }
}
```

### JSON Secret (Database Credentials)

```hcl
module "db_credentials" {
  source = "path/to/modules/secrets-manager"

  name = "my-app/database"

  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
    host     = module.rds.endpoint
    port     = 5432
    dbname   = "myapp"
  })
}
```

### Secret with Custom KMS Key

```hcl
module "encrypted_secret" {
  source = "path/to/modules/secrets-manager"

  name          = "my-app/sensitive-data"
  secret_string = var.sensitive_data
  kms_key_id    = module.kms_key.key_id
}
```

### Secret with Rotation

```hcl
module "rotating_secret" {
  source = "path/to/modules/secrets-manager"

  name          = "my-app/rotating-key"
  secret_string = var.initial_key

  enable_rotation     = true
  rotation_lambda_arn = aws_lambda_function.rotator.arn
  rotation_days       = 30
}
```

### Secret with Cron Rotation Schedule

```hcl
module "scheduled_rotation" {
  source = "path/to/modules/secrets-manager"

  name          = "my-app/scheduled-secret"
  secret_string = var.secret_value

  enable_rotation              = true
  rotation_lambda_arn          = aws_lambda_function.rotator.arn
  rotation_schedule_expression = "cron(0 16 1,15 * ? *)"  # 1st and 15th at 4pm UTC
}
```

### Multi-Region Secret

```hcl
module "global_secret" {
  source = "path/to/modules/secrets-manager"

  name          = "global/api-key"
  secret_string = var.api_key

  replica_regions = [
    {
      region = "us-west-2"
    },
    {
      region     = "eu-west-1"
      kms_key_id = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }
  ]
}
```

### Secret with Resource Policy

```hcl
module "shared_secret" {
  source = "path/to/modules/secrets-manager"

  name          = "shared/credentials"
  secret_string = var.credentials

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::987654321098:root"
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      }
    ]
  })
}
```

### Placeholder Secret (Value Set Externally)

```hcl
module "external_secret" {
  source = "path/to/modules/secrets-manager"

  name        = "my-app/external-secret"
  description = "Secret value managed externally"

  # No secret_string provided - value will be set externally
}
```

### Immediate Deletion (Development)

```hcl
module "dev_secret" {
  source = "path/to/modules/secrets-manager"

  name          = "dev/test-secret"
  secret_string = "test-value"

  recovery_window_in_days = 0  # Immediate deletion

  tags = {
    Environment = "development"
  }
}
```

## Features

- **Secret Values**: Store string or binary secrets
- **Encryption**: AWS-managed or customer-managed KMS keys
- **Rotation**: Automatic rotation with Lambda functions
- **Replication**: Multi-region secret replication
- **Resource Policies**: Control access to secrets
- **Versioning**: Automatic version management

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the secret | `string` | n/a | yes |
| secret_string | Secret string value | `string` | `""` | no |
| secret_binary | Secret binary value (base64) | `string` | `""` | no |
| ignore_secret_changes | Ignore changes to secret value | `bool` | `true` | no |
| kms_key_id | KMS key for encryption | `string` | `""` | no |
| enable_rotation | Enable automatic rotation | `bool` | `false` | no |
| rotation_lambda_arn | Lambda ARN for rotation | `string` | `""` | no |
| rotation_days | Days between rotations | `number` | `30` | no |
| rotation_schedule_expression | Cron/rate expression for rotation | `string` | `""` | no |
| replica_regions | Regions for replication | `list(object)` | `[]` | no |
| policy | Resource policy JSON | `string` | `""` | no |
| description | Secret description | `string` | `""` | no |
| recovery_window_in_days | Days before deletion (0 or 7-30) | `number` | `30` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the secret |
| arn | The ARN of the secret |
| name | The name of the secret |
| version_id | The version ID of the secret |
| version_stages | The version stages |
| replica_status | Status of secret replicas |

## Retrieving Secret Values

### AWS CLI

```bash
aws secretsmanager get-secret-value --secret-id my-app/api-key --query SecretString --output text
```

### Terraform Data Source

```hcl
data "aws_secretsmanager_secret_version" "example" {
  secret_id = module.my_secret.id
}

locals {
  secret_value = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)
}
```

### Application Code (Python)

```python
import boto3
import json

client = boto3.client('secretsmanager')
response = client.get_secret_value(SecretId='my-app/api-key')
secret = json.loads(response['SecretString'])
```
