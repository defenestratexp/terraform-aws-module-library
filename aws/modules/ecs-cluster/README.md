# ECS Cluster Module

Creates an AWS ECS cluster with capacity providers, Container Insights, and optional ECS Exec configuration.

## Usage

### Basic Fargate Cluster

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "my-cluster"

  tags = {
    Environment = "production"
  }
}
```

### Fargate with Spot

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "my-cluster"

  enable_fargate      = true
  enable_fargate_spot = true

  # Use Fargate Spot for cost savings with fallback to regular Fargate
  default_capacity_provider = "FARGATE_SPOT"
  capacity_provider_weights = {
    fargate      = 1
    fargate_spot = 4  # Prefer Spot 4:1
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster with EC2 Capacity Provider

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "my-cluster"

  # Disable Fargate, use EC2 only
  enable_fargate      = false
  enable_fargate_spot = false

  autoscaling_capacity_providers = {
    ec2-ondemand = {
      auto_scaling_group_arn         = module.asg.arn
      managed_termination_protection = "ENABLED"
      managed_scaling = {
        status          = "ENABLED"
        target_capacity = 90
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Mixed Fargate and EC2

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "my-cluster"

  enable_fargate      = true
  enable_fargate_spot = true

  autoscaling_capacity_providers = {
    ec2-spot = {
      auto_scaling_group_arn = module.spot_asg.arn
      managed_scaling = {
        status                    = "ENABLED"
        target_capacity           = 100
        minimum_scaling_step_size = 1
        maximum_scaling_step_size = 10
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster with ECS Exec

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "my-cluster"

  # Enable CloudWatch logging for ECS Exec
  create_cloudwatch_log_group    = true
  cloudwatch_log_group_retention = 30

  execute_command_configuration = {
    logging = "OVERRIDE"
    log_configuration = {
      cloud_watch_encryption_enabled = true
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster with ECS Exec and KMS Encryption

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "secure-cluster"

  create_cloudwatch_log_group     = true
  cloudwatch_log_group_retention  = 90
  cloudwatch_log_group_kms_key_id = module.kms_key.arn

  execute_command_configuration = {
    kms_key_id = module.kms_key.id
    logging    = "OVERRIDE"
    log_configuration = {
      cloud_watch_encryption_enabled = true
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster with Service Connect

```hcl
# First create a Cloud Map namespace
resource "aws_service_discovery_http_namespace" "main" {
  name = "my-apps"
}

module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "my-cluster"

  service_connect_defaults = {
    namespace = aws_service_discovery_http_namespace.main.arn
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster without Container Insights

```hcl
module "ecs_cluster" {
  source = "path/to/modules/ecs-cluster"

  name = "dev-cluster"

  # Disable Container Insights to save costs in dev
  enable_container_insights = false

  tags = {
    Environment = "development"
  }
}
```

## Features

- **Fargate Support**: Serverless container execution
- **Fargate Spot**: Cost-optimized Fargate with interruption tolerance
- **EC2 Capacity Providers**: Auto Scaling Group integration with managed scaling
- **Container Insights**: CloudWatch monitoring and metrics
- **ECS Exec**: Interactive shell access to containers
- **Service Connect**: Service mesh for ECS services

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Cluster name | `string` | n/a | yes |
| enable_container_insights | Enable Container Insights | `bool` | `true` | no |
| enable_fargate | Enable Fargate provider | `bool` | `true` | no |
| enable_fargate_spot | Enable Fargate Spot | `bool` | `false` | no |
| default_capacity_provider | Default capacity provider | `string` | `"FARGATE"` | no |
| capacity_provider_weights | Weights for providers | `object` | `{fargate=1}` | no |
| autoscaling_capacity_providers | ASG capacity providers | `map(object)` | `{}` | no |
| service_connect_defaults | Service Connect config | `object` | `null` | no |
| execute_command_configuration | ECS Exec configuration | `object` | `null` | no |
| create_cloudwatch_log_group | Create log group for Exec | `bool` | `false` | no |
| cloudwatch_log_group_retention | Log retention days | `number` | `30` | no |
| cloudwatch_log_group_kms_key_id | KMS key for logs | `string` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The cluster ID |
| arn | The cluster ARN |
| name | The cluster name |
| capacity_providers | List of capacity providers |
| asg_capacity_provider_names | Map of ASG provider names to ARNs |
| exec_log_group_name | ECS Exec log group name |
| exec_log_group_arn | ECS Exec log group ARN |

## Capacity Provider Strategy

The capacity provider strategy determines how tasks are distributed:

- **base**: Minimum number of tasks on this provider
- **weight**: Relative proportion of tasks (higher = more tasks)

Example: `fargate=1, fargate_spot=4` means 80% Spot, 20% regular Fargate.

## ECS Exec

To use ECS Exec for debugging:

```bash
aws ecs execute-command \
  --cluster my-cluster \
  --task <task-id> \
  --container <container-name> \
  --interactive \
  --command "/bin/sh"
```

Requirements:
- Task role must have SSM permissions
- Platform version 1.4.0+ (Fargate)
- `enableExecuteCommand` in task definition

## Considerations

- Container Insights incurs CloudWatch costs
- Fargate Spot tasks can be interrupted with 2-minute warning
- EC2 capacity providers require an existing ASG
- ECS Exec requires SSM agent and proper IAM permissions
