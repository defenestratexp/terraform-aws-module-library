# IAM Policy Module

Creates a standalone IAM policy that can be attached to roles, users, or groups.

## Usage

### Using JSON Policy Document

```hcl
module "s3_read_policy" {
  source = "path/to/modules/iam-policy"

  name        = "s3-read-access"
  description = "Read access to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}
```

### Using Statements

```hcl
module "dynamodb_policy" {
  source = "path/to/modules/iam-policy"

  name        = "dynamodb-access"
  description = "Access to DynamoDB tables"

  statements = [
    {
      sid     = "ReadItems"
      effect  = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      resources = [
        "arn:aws:dynamodb:*:*:table/my-table",
        "arn:aws:dynamodb:*:*:table/my-table/index/*"
      ]
    },
    {
      sid     = "WriteItems"
      effect  = "Allow"
      actions = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ]
      resources = [
        "arn:aws:dynamodb:*:*:table/my-table"
      ]
    }
  ]
}
```

### Policy with Conditions

```hcl
module "restricted_policy" {
  source = "path/to/modules/iam-policy"

  name = "vpc-restricted-access"

  statements = [
    {
      sid       = "VPCRestricted"
      effect    = "Allow"
      actions   = ["ec2:*"]
      resources = ["*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "ec2:Vpc"
          values   = ["arn:aws:ec2:us-east-1:123456789012:vpc/vpc-12345678"]
        }
      ]
    }
  ]
}
```

### Secrets Manager Access Policy

```hcl
module "secrets_policy" {
  source = "path/to/modules/iam-policy"

  name = "secrets-read-access"

  statements = [
    {
      sid     = "ReadSecrets"
      effect  = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = [
        "arn:aws:secretsmanager:*:*:secret:my-app/*"
      ]
    },
    {
      sid     = "DecryptSecrets"
      effect  = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [
        "arn:aws:kms:*:*:key/*"
      ]
      conditions = [
        {
          test     = "StringEquals"
          variable = "kms:ViaService"
          values   = ["secretsmanager.us-east-1.amazonaws.com"]
        }
      ]
    }
  ]
}
```

### Attaching to a Role

```hcl
module "my_policy" {
  source = "path/to/modules/iam-policy"

  name = "my-custom-policy"

  statements = [
    {
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::my-bucket/*"]
    }
  ]
}

module "my_role" {
  source = "path/to/modules/iam-role"

  name             = "my-role"
  trusted_services = ["lambda.amazonaws.com"]

  managed_policy_arns = [
    module.my_policy.arn
  ]
}
```

## Features

- **Flexible Input**: Use JSON policy or structured statements
- **Conditions**: Support for IAM policy conditions
- **Multiple Statements**: Combine multiple permission statements
- **Reusable**: Attach to multiple roles, users, or groups

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the IAM policy | `string` | n/a | yes |
| policy | JSON policy document | `string` | `""` | no |
| statements | List of policy statements | `list(object)` | `[]` | no |
| description | Description of the policy | `string` | `""` | no |
| path | Path for the policy | `string` | `"/"` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The policy ID |
| arn | The ARN of the policy |
| name | The name of the policy |
| path | The path of the policy |
| policy | The policy document |
| policy_id | The policy's ID |

## Statement Object

| Field | Description | Required |
|-------|-------------|----------|
| sid | Statement ID | No |
| effect | Allow or Deny | No (default: Allow) |
| actions | List of IAM actions | Yes |
| resources | List of resource ARNs | Yes |
| conditions | List of conditions | No |
