# IAM Role Module

Creates an IAM role with flexible assume role policy and policy attachments.

## Usage

### Role for EC2 Instances

```hcl
module "ec2_role" {
  source = "path/to/modules/iam-role"

  name             = "my-ec2-role"
  trusted_services = ["ec2.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Role for Lambda Functions

```hcl
module "lambda_role" {
  source = "path/to/modules/iam-role"

  name             = "my-lambda-role"
  trusted_services = ["lambda.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policies = {
    s3-access = jsonencode({
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

### Cross-Account Role

```hcl
module "cross_account_role" {
  source = "path/to/modules/iam-role"

  name             = "cross-account-admin"
  trusted_accounts = ["123456789012", "987654321098"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  assume_role_condition = [
    {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  ]
}
```

### Role for EKS Service Account (IRSA)

```hcl
module "eks_pod_role" {
  source = "path/to/modules/iam-role"

  name = "my-app-pod-role"

  trusted_oidc_providers = [
    {
      provider_arn = module.eks.oidc_provider_arn
      client_ids   = ["sts.amazonaws.com"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "${module.eks.oidc_provider}:sub"
          values   = ["system:serviceaccount:my-namespace:my-service-account"]
        }
      ]
    }
  ]

  inline_policies = {
    secrets-access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue"]
          Resource = "arn:aws:secretsmanager:*:*:secret:my-app/*"
        }
      ]
    })
  }
}
```

### Role Assumed by Another Role

```hcl
module "deployment_role" {
  source = "path/to/modules/iam-role"

  name = "deployment-role"

  trusted_roles = [
    "arn:aws:iam::123456789012:role/ci-cd-role"
  ]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```

### Custom Assume Role Policy

```hcl
module "custom_role" {
  source = "path/to/modules/iam-role"

  name = "custom-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:us-east-1:123456789012:*"
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}
```

## Features

- **Flexible Trust**: Trust AWS services, accounts, roles, or OIDC providers
- **Policy Attachments**: Attach managed and inline policies
- **Conditions**: Add conditions to assume role policy
- **OIDC Support**: Full support for OIDC providers (EKS IRSA, GitHub Actions, etc.)
- **Permissions Boundary**: Support for permissions boundaries
- **Session Duration**: Configurable max session duration

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the IAM role | `string` | n/a | yes |
| assume_role_policy | Custom JSON assume role policy | `string` | `""` | no |
| trusted_services | AWS services that can assume the role | `list(string)` | `[]` | no |
| trusted_accounts | AWS account IDs that can assume the role | `list(string)` | `[]` | no |
| trusted_roles | IAM role ARNs that can assume the role | `list(string)` | `[]` | no |
| trusted_oidc_providers | OIDC provider configurations | `list(object)` | `[]` | no |
| assume_role_condition | Additional conditions for assume role | `list(object)` | `[]` | no |
| managed_policy_arns | Managed policy ARNs to attach | `list(string)` | `[]` | no |
| inline_policies | Map of inline policy names to documents | `map(string)` | `{}` | no |
| description | Description of the role | `string` | `""` | no |
| path | Path for the role | `string` | `"/"` | no |
| max_session_duration | Maximum session duration (3600-43200) | `number` | `3600` | no |
| permissions_boundary | ARN of permissions boundary policy | `string` | `""` | no |
| force_detach_policies | Force detach policies before destroy | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the role |
| arn | The ARN of the role |
| name | The name of the role |
| unique_id | The unique ID of the role |
| create_date | The creation date of the role |
| assume_role_policy | The assume role policy document |

## Common Trusted Services

| Service | Principal |
|---------|-----------|
| EC2 | `ec2.amazonaws.com` |
| Lambda | `lambda.amazonaws.com` |
| ECS Tasks | `ecs-tasks.amazonaws.com` |
| EKS | `eks.amazonaws.com` |
| API Gateway | `apigateway.amazonaws.com` |
| CloudWatch Events | `events.amazonaws.com` |
| Step Functions | `states.amazonaws.com` |
| CodeBuild | `codebuild.amazonaws.com` |
| CodePipeline | `codepipeline.amazonaws.com` |
