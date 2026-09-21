# ECR Repository Module

Creates an AWS ECR repository with lifecycle policies, access controls, and optional replication.

## Usage

### Basic Repository

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name = "my-app"

  tags = {
    Environment = "production"
  }
}
```

### Repository with Immutable Tags

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name                 = "my-app"
  image_tag_mutability = "IMMUTABLE"

  tags = {
    Environment = "production"
  }
}
```

### Repository with KMS Encryption

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name            = "secure-app"
  encryption_type = "KMS"
  kms_key_arn     = module.kms_key.arn

  tags = {
    Environment = "production"
  }
}
```

### Repository with Custom Lifecycle Policy

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name = "my-app"

  # Keep more images and longer untagged retention
  max_image_count            = 100
  untagged_image_expiry_days = 14

  tags = {
    Environment = "production"
  }
}
```

### Repository with Cross-Account Access

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name = "shared-app"

  # Allow other accounts to pull
  allow_pull_accounts = [
    "111111111111",  # Dev account
    "222222222222",  # Staging account
  ]

  # Allow CI/CD account to push
  allow_push_accounts = ["333333333333"]

  tags = {
    Environment = "shared"
  }
}
```

### Repository with Lambda Access

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name = "lambda-app"

  # Allow Lambda to pull images
  allow_lambda_pull = true

  tags = {
    Environment = "production"
  }
}
```

### Repository with Replication

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name = "replicated-app"

  # Replicate to other regions
  replication_destinations = [
    { region = "us-west-2" },
    { region = "eu-west-1" },
  ]

  tags = {
    Environment = "production"
  }
}
```

### Repository with Cross-Account Replication

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name = "cross-account-app"

  # Replicate to other account
  replication_destinations = [
    {
      region      = "us-east-1"
      registry_id = "111111111111"  # DR account
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Repository with Custom Lifecycle Policy

```hcl
module "ecr_repository" {
  source = "path/to/modules/ecr-repository"

  name                    = "custom-lifecycle-app"
  enable_lifecycle_policy = true

  custom_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep prod images forever"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod-"]
          countType     = "imageCountMoreThan"
          countNumber   = 9999
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 10 dev images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev-"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Expire untagged after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Image Scanning**: Automatic vulnerability scanning on push
- **Tag Mutability**: Support for immutable tags
- **Encryption**: AES256 or KMS encryption
- **Lifecycle Policies**: Automatic image cleanup
- **Cross-Account Access**: Pull/push permissions for other accounts
- **Lambda Integration**: Allow Lambda to pull container images
- **Replication**: Cross-region and cross-account replication

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Repository name | `string` | n/a | yes |
| image_tag_mutability | Tag mutability (MUTABLE/IMMUTABLE) | `string` | `"MUTABLE"` | no |
| force_delete | Delete even with images | `bool` | `false` | no |
| encryption_type | Encryption type (AES256/KMS) | `string` | `"AES256"` | no |
| kms_key_arn | KMS key ARN for encryption | `string` | `null` | no |
| scan_on_push | Enable scan on push | `bool` | `true` | no |
| enable_lifecycle_policy | Enable lifecycle policy | `bool` | `true` | no |
| max_image_count | Max images to keep | `number` | `30` | no |
| untagged_image_expiry_days | Days until untagged expire | `number` | `7` | no |
| custom_lifecycle_policy | Custom lifecycle policy JSON | `string` | `null` | no |
| repository_policy | Custom repository policy JSON | `string` | `null` | no |
| allow_pull_accounts | Accounts allowed to pull | `list(string)` | `[]` | no |
| allow_push_accounts | Accounts allowed to push | `list(string)` | `[]` | no |
| allow_lambda_pull | Allow Lambda to pull | `bool` | `false` | no |
| replication_destinations | Replication destinations | `list(object)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The registry ID |
| arn | The repository ARN |
| name | The repository name |
| repository_url | The repository URL |
| registry_id | The registry ID |
| image_uri_latest | Repository URL with :latest tag |
| push_commands | Docker push commands |

## Docker Commands

After creating the repository, use the output `push_commands` to push images:

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build, tag, and push
docker build -t my-app .
docker tag my-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

## Considerations

- Repository names must be unique within a registry
- Immutable tags prevent overwriting (good for production)
- Lifecycle policies help control storage costs
- Cross-account replication requires permissions in destination
- Image scanning results available in ECR console or API
