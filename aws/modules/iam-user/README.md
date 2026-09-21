# IAM User Module

Creates an IAM user with optional access keys, login profile, and policy attachments.

## Usage

### Basic Service Account

```hcl
module "service_user" {
  source = "path/to/modules/iam-user"

  name              = "app-service-account"
  create_access_key = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Purpose = "Application service account"
  }
}

output "access_key_id" {
  value = module.service_user.access_key_id
}

output "secret_access_key" {
  value     = module.service_user.secret_access_key
  sensitive = true
}
```

### User with Console Access

```hcl
module "admin_user" {
  source = "path/to/modules/iam-user"

  name                 = "admin-user"
  create_login_profile = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  pgp_key = "keybase:myusername"
}

output "encrypted_password" {
  value = module.admin_user.encrypted_password
}
```

### User with Inline Policy

```hcl
module "limited_user" {
  source = "path/to/modules/iam-user"

  name              = "limited-user"
  create_access_key = true

  inline_policies = {
    s3-specific = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:PutObject"]
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
  }
}
```

### User in Groups

```hcl
module "developer_user" {
  source = "path/to/modules/iam-user"

  name                 = "developer"
  create_login_profile = true
  create_access_key    = true

  groups = [
    "developers",
    "readonly-production"
  ]

  pgp_key = "keybase:developer"
}
```

### CI/CD Service Account

```hcl
module "cicd_user" {
  source = "path/to/modules/iam-user"

  name              = "github-actions"
  create_access_key = true
  path              = "/ci-cd/"

  inline_policies = {
    ecr-push = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload"
          ]
          Resource = "arn:aws:ecr:*:*:repository/my-app"
        },
        {
          Effect   = "Allow"
          Action   = "ecr:GetAuthorizationToken"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    Purpose = "GitHub Actions CI/CD"
  }
}
```

### Using PGP Encryption

```hcl
# Generate and encode your PGP public key
# gpg --export <key-id> | base64

module "secure_user" {
  source = "path/to/modules/iam-user"

  name                 = "secure-user"
  create_access_key    = true
  create_login_profile = true

  pgp_key = "keybase:myusername"
  # or base64-encoded PGP public key
  # pgp_key = "mQENBF..."
}

# Decrypt the secret access key:
# terraform output -raw encrypted_secret | base64 -d | gpg -d

# Decrypt the password:
# terraform output -raw encrypted_password | base64 -d | gpg -d
```

## Features

- **Access Keys**: Create programmatic access credentials
- **Login Profile**: Create console access with password
- **PGP Encryption**: Encrypt sensitive outputs with PGP/Keybase
- **Policy Attachments**: Attach managed and inline policies
- **Group Membership**: Add user to IAM groups
- **Permissions Boundary**: Limit maximum permissions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the IAM user | `string` | n/a | yes |
| create_access_key | Create an access key | `bool` | `false` | no |
| access_key_status | Status of access key (Active/Inactive) | `string` | `"Active"` | no |
| pgp_key | PGP key for encrypting secrets | `string` | `""` | no |
| create_login_profile | Create console login profile | `bool` | `false` | no |
| password_length | Generated password length | `number` | `20` | no |
| password_reset_required | Require password reset on first login | `bool` | `true` | no |
| managed_policy_arns | Managed policy ARNs to attach | `list(string)` | `[]` | no |
| inline_policies | Map of inline policy names to documents | `map(string)` | `{}` | no |
| groups | IAM groups to add user to | `list(string)` | `[]` | no |
| path | Path for the user | `string` | `"/"` | no |
| permissions_boundary | Permissions boundary policy ARN | `string` | `""` | no |
| force_destroy | Force destroy even with non-TF access keys | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The user's name |
| arn | The ARN of the user |
| unique_id | The unique ID of the user |
| access_key_id | The access key ID |
| secret_access_key | The secret access key (if no PGP key) |
| encrypted_secret | The encrypted secret (if PGP key used) |
| encrypted_password | The encrypted password (if PGP key used) |
| key_fingerprint | The PGP key fingerprint |

## Security Considerations

- Avoid creating access keys for human users - use SSO instead
- Use PGP encryption for any credentials that must be in state
- Consider using IAM roles with OIDC for CI/CD instead of access keys
- Rotate access keys regularly
- Use permissions boundaries to limit blast radius
