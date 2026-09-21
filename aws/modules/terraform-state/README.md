# Terraform State Backend Module

Creates an S3 bucket and DynamoDB table for Terraform remote state management.

## Features

- S3 bucket with server-side encryption (AES256 or KMS)
- DynamoDB table for state locking with PAY_PER_REQUEST billing
- Public access blocked on S3 bucket
- TLS enforced via bucket policy
- Optional versioning with noncurrent version expiration
- Point-in-time recovery enabled on DynamoDB table

## Usage

### Basic Usage

```hcl
module "terraform_state" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/terraform-state?ref=v1.0.0"

  name = "acme-corp"
}
```

This creates:
- S3 bucket: `acme-corp-tfstate`
- DynamoDB table: `acme-corp-tfstate-lock`

### With Custom Options

```hcl
module "terraform_state" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/terraform-state?ref=v1.0.0"

  name                               = "acme-corp"
  enable_versioning                  = true
  noncurrent_version_expiration_days = 30

  tags = {
    Client      = "ACME Corp"
    Environment = "shared"
    Project     = "infrastructure"
  }
}
```

### With KMS Encryption

```hcl
module "terraform_state" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/terraform-state?ref=v1.0.0"

  name        = "acme-corp"
  kms_key_arn = aws_kms_key.terraform.arn
}
```

## Bootstrap Process

This module is used to bootstrap Terraform state management for a new client/project:

1. **Create bootstrap configuration:**

```hcl
# _bootstrap/main.tf
provider "aws" {
  region = "us-west-2"
}

module "terraform_state" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/terraform-state"

  name = "acme-corp"

  tags = {
    Client = "ACME Corp"
  }
}

output "backend_config" {
  value = module.terraform_state.backend_config_hcl
}
```

2. **Run bootstrap (uses local state initially):**

```bash
cd _bootstrap
terraform init
terraform apply
```

3. **Copy backend configuration from output to your environment:**

```hcl
# environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "acme-corp-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "acme-corp-tfstate-lock"
    encrypt        = true
  }
}
```

4. **(Optional) Migrate bootstrap state to S3:**

```bash
# Add backend.tf to _bootstrap with key = "bootstrap/terraform.tfstate"
terraform init -migrate-state
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for resources (e.g., client name) | `string` | n/a | yes |
| bucket_suffix | Suffix for bucket name | `string` | `"tfstate"` | no |
| table_suffix | Suffix for DynamoDB table name | `string` | `"tfstate-lock"` | no |
| enable_versioning | Enable S3 versioning | `bool` | `true` | no |
| noncurrent_version_expiration_days | Days to retain old versions (0 = forever) | `number` | `90` | no |
| kms_key_arn | KMS key ARN for encryption (uses AES256 if empty) | `string` | `""` | no |
| enable_replication | Enable cross-region replication | `bool` | `false` | no |
| replication_region | Region for replication | `string` | `""` | no |
| force_destroy | Allow bucket destruction with contents | `bool` | `false` | no |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | Name of the S3 bucket |
| bucket_arn | ARN of the S3 bucket |
| bucket_region | Region of the S3 bucket |
| dynamodb_table_name | Name of the DynamoDB table |
| dynamodb_table_arn | ARN of the DynamoDB table |
| backend_config | Map of backend configuration values |
| backend_config_hcl | HCL snippet for backend.tf |

## Security Features

- **Encryption at rest:** AES256 (default) or KMS
- **Encryption in transit:** TLS enforced via bucket policy
- **Public access:** Blocked at bucket level
- **State locking:** DynamoDB prevents concurrent modifications
- **Point-in-time recovery:** Enabled on DynamoDB table

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |
