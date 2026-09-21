# ECS Task Definition Module

Creates an ECS task definition with optional IAM roles and volume configurations.

## Usage

### Basic Fargate Task

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-app"
  cpu    = 256
  memory = 512

  container_definitions = [
    {
      name      = "app"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Task with ECR Image and Logging

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-app"
  cpu    = 512
  memory = 1024

  create_execution_role = true

  container_definitions = [
    {
      name      = "app"
      image     = "${module.ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/my-app"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "app"
        }
      }
      environment = [
        { name = "NODE_ENV", value = "production" }
      ]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Task with IAM Roles

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-app"
  cpu    = 256
  memory = 512

  create_task_role      = true
  create_execution_role = true

  # Task role can access S3 and DynamoDB
  task_role_policies = {
    s3       = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    dynamodb = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  }

  # Custom inline policy
  task_role_inline_policies = {
    secrets = jsonencode({
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

  container_definitions = [
    {
      name      = "app"
      image     = "my-app:latest"
      essential = true
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Task with EFS Volume

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-app"
  cpu    = 256
  memory = 512

  volumes = [
    {
      name = "data"
      efs_volume_configuration = {
        file_system_id     = module.efs.id
        root_directory     = "/"
        transit_encryption = "ENABLED"
        authorization_config = {
          access_point_id = module.efs.access_point_id
          iam             = "ENABLED"
        }
      }
    }
  ]

  container_definitions = [
    {
      name      = "app"
      image     = "my-app:latest"
      essential = true
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
          readOnly      = false
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Task with Multiple Containers

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-app"
  cpu    = 512
  memory = 1024

  container_definitions = [
    {
      name      = "app"
      image     = "my-app:latest"
      essential = true
      cpu       = 384
      memory    = 768
      portMappings = [
        { containerPort = 8080, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "envoy", condition = "HEALTHY" }
      ]
    },
    {
      name      = "envoy"
      image     = "envoyproxy/envoy:v1.25.0"
      essential = true
      cpu       = 128
      memory    = 256
      portMappings = [
        { containerPort = 9901, protocol = "tcp" }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -s http://localhost:9901/ready"]
        interval    = 5
        timeout     = 2
        retries     = 3
        startPeriod = 10
      }
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### ARM64 Task (Graviton)

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-app-arm"
  cpu    = 256
  memory = 512

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = [
    {
      name      = "app"
      image     = "my-app:latest-arm64"
      essential = true
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Windows Task

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "my-windows-app"
  cpu    = 1024
  memory = 2048

  runtime_platform = {
    operating_system_family = "WINDOWS_SERVER_2019_FULL"
    cpu_architecture        = "X86_64"
  }

  container_definitions = [
    {
      name      = "app"
      image     = "mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019"
      essential = true
      portMappings = [
        { containerPort = 80, protocol = "tcp" }
      ]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Task with Extra Ephemeral Storage

```hcl
module "task_definition" {
  source = "path/to/modules/ecs-task-definition"

  family = "data-processor"
  cpu    = 1024
  memory = 2048

  # Additional ephemeral storage (default is 20GB)
  ephemeral_storage_size_gib = 100

  container_definitions = [
    {
      name      = "processor"
      image     = "data-processor:latest"
      essential = true
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Fargate & EC2**: Support for both launch types
- **IAM Roles**: Optional task and execution role creation
- **Volumes**: EFS, Docker volumes, and host paths
- **Multi-Architecture**: x86_64 and ARM64 support
- **Windows**: Windows container support
- **Ephemeral Storage**: Configurable ephemeral storage (Fargate)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| family | Task definition family name | `string` | n/a | yes |
| container_definitions | Container definitions | `any` | n/a | yes |
| cpu | CPU units | `number` | `256` | no |
| memory | Memory (MB) | `number` | `512` | no |
| requires_compatibilities | Launch type (FARGATE, EC2) | `list(string)` | `["FARGATE"]` | no |
| network_mode | Network mode | `string` | `"awsvpc"` | no |
| runtime_platform | Runtime platform config | `object` | `null` | no |
| task_role_arn | Task role ARN | `string` | `null` | no |
| execution_role_arn | Execution role ARN | `string` | `null` | no |
| create_task_role | Create task role | `bool` | `false` | no |
| create_execution_role | Create execution role | `bool` | `false` | no |
| task_role_policies | Task role policies | `map(string)` | `{}` | no |
| task_role_inline_policies | Task role inline policies | `map(string)` | `{}` | no |
| volumes | Volume configurations | `list(object)` | `[]` | no |
| ephemeral_storage_size_gib | Ephemeral storage GiB | `number` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Task definition ARN |
| arn_without_revision | ARN without revision |
| family | Task definition family |
| revision | Task definition revision |
| task_role_arn | Task role ARN |
| task_role_name | Task role name |
| execution_role_arn | Execution role ARN |
| execution_role_name | Execution role name |

## Fargate CPU/Memory Combinations

| CPU (units) | Memory (MB) |
|-------------|-------------|
| 256 | 512, 1024, 2048 |
| 512 | 1024 - 4096 |
| 1024 | 2048 - 8192 |
| 2048 | 4096 - 16384 |
| 4096 | 8192 - 30720 |
| 8192 | 16384 - 61440 |
| 16384 | 32768 - 122880 |

## Considerations

- Fargate requires `awsvpc` network mode
- Execution role is required for ECR images and CloudWatch Logs
- Task role is for permissions needed by the application
- Container definitions can be JSON string or list of objects
