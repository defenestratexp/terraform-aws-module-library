# IAM Instance Profile Module

Creates an IAM instance profile for EC2 instances with an optional IAM role.

## Usage

### Basic Instance Profile with SSM Access

```hcl
module "ec2_profile" {
  source = "path/to/modules/iam-instance-profile"

  name = "my-ec2-profile"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    Environment = "production"
  }
}

# Use in EC2 instance
resource "aws_instance" "example" {
  ami                  = "ami-12345678"
  instance_type        = "t3.micro"
  iam_instance_profile = module.ec2_profile.name
}
```

### Instance Profile with Custom Policies

```hcl
module "app_profile" {
  source = "path/to/modules/iam-instance-profile"

  name = "app-server-profile"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  inline_policies = {
    s3-access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::my-app-bucket/*"
        }
      ]
    })

    secrets-access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "secretsmanager:GetSecretValue"
          Resource = "arn:aws:secretsmanager:*:*:secret:my-app/*"
        }
      ]
    })
  }
}
```

### Instance Profile with Existing Role

```hcl
module "existing_role_profile" {
  source = "path/to/modules/iam-instance-profile"

  name        = "my-profile"
  create_role = false
  role_arn    = "arn:aws:iam::123456789012:role/existing-role"
}
```

### Instance Profile for ECS Container Instances

```hcl
module "ecs_instance_profile" {
  source = "path/to/modules/iam-instance-profile"

  name = "ecs-container-instance"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
```

### Instance Profile with Permissions Boundary

```hcl
module "bounded_profile" {
  source = "path/to/modules/iam-instance-profile"

  name = "bounded-profile"

  permissions_boundary = "arn:aws:iam::123456789012:policy/PermissionsBoundary"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```

### Using with Launch Template

```hcl
module "asg_profile" {
  source = "path/to/modules/iam-instance-profile"

  name = "asg-instance-profile"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

module "launch_template" {
  source = "path/to/modules/launch-template"

  name                     = "my-launch-template"
  instance_type            = "t3.medium"
  iam_instance_profile_arn = module.asg_profile.arn

  # ... other settings
}
```

## Features

- **Role Creation**: Optionally create a new IAM role or use an existing one
- **Policy Attachments**: Attach managed and inline policies
- **EC2 Trust**: Pre-configured trust policy for EC2 service
- **Permissions Boundary**: Support for permissions boundaries

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the instance profile | `string` | n/a | yes |
| role_arn | ARN of existing IAM role | `string` | `""` | no |
| create_role | Create a new IAM role | `bool` | `true` | no |
| trusted_services | Services that can assume the role | `list(string)` | `["ec2.amazonaws.com"]` | no |
| managed_policy_arns | Managed policy ARNs to attach | `list(string)` | `[]` | no |
| inline_policies | Map of inline policy names to documents | `map(string)` | `{}` | no |
| path | Path for instance profile and role | `string` | `"/"` | no |
| permissions_boundary | Permissions boundary policy ARN | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The instance profile ID |
| arn | The ARN of the instance profile |
| name | The name of the instance profile |
| unique_id | The unique ID of the instance profile |
| role_arn | The ARN of the IAM role |
| role_name | The name of the IAM role |
| role_id | The ID of the IAM role |

## Common Managed Policies

| Policy | Description |
|--------|-------------|
| `AmazonSSMManagedInstanceCore` | Systems Manager access for EC2 |
| `CloudWatchAgentServerPolicy` | CloudWatch agent permissions |
| `AmazonEC2ContainerServiceforEC2Role` | ECS container instance |
| `AmazonEKSWorkerNodePolicy` | EKS worker node |
| `AmazonEC2RoleforAWSCodeDeploy` | CodeDeploy agent |
| `AmazonS3ReadOnlyAccess` | S3 read-only access |
