# ECS Service Module

Creates an ECS service with load balancing, auto scaling, and deployment configuration.

## Usage

### Basic Fargate Service

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "my-app"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 2

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  tags = {
    Environment = "production"
  }
}
```

### Service with Load Balancer

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "web-app"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 3

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  load_balancers = [
    {
      target_group_arn = module.alb.target_group_arn
      container_name   = "app"
      container_port   = 8080
    }
  ]

  health_check_grace_period_seconds = 60

  tags = {
    Environment = "production"
  }
}
```

### Service with Auto Scaling

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "scalable-app"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 2

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  # Auto scaling
  enable_autoscaling       = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 20

  autoscaling_policies = {
    cpu = {
      target_tracking = {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        target_value           = 70
        scale_in_cooldown      = 300
        scale_out_cooldown     = 60
      }
    }
    memory = {
      target_tracking = {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        target_value           = 80
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Service with Capacity Provider Strategy

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "mixed-capacity-app"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 4

  # Use Fargate Spot primarily with Fargate fallback
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1  # Always keep 1 task on regular Fargate
    }
  ]

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  tags = {
    Environment = "production"
  }
}
```

### Service with Service Discovery

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "api-service"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 2

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  service_registries = [
    {
      registry_arn = aws_service_discovery_service.api.arn
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Service with Service Connect

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "backend-service"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 2

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  service_connect_configuration = {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.main.arn
    service = {
      port_name      = "http"
      discovery_name = "backend"
      client_alias = {
        port     = 8080
        dns_name = "backend"
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Service with ECS Exec

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "debug-app"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn

  desired_count = 1

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.id]

  # Enable ECS Exec for debugging
  enable_execute_command = true

  tags = {
    Environment = "development"
  }
}
```

### EC2 Service with Placement Strategy

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "ec2-app"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn
  launch_type         = "EC2"

  desired_count = 6

  # Spread across AZs, then bin pack by memory
  ordered_placement_strategy = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "binpack"
      field = "memory"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Daemon Service

```hcl
module "ecs_service" {
  source = "path/to/modules/ecs-service"

  name                = "log-agent"
  cluster_id          = module.ecs_cluster.id
  task_definition_arn = module.task_definition.arn
  launch_type         = "EC2"

  scheduling_strategy = "DAEMON"

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Load Balancing**: ALB/NLB target group integration
- **Auto Scaling**: Target tracking scaling policies
- **Capacity Providers**: Fargate, Fargate Spot, EC2
- **Service Connect**: Service mesh integration
- **Service Discovery**: Cloud Map integration
- **Deployment Circuit Breaker**: Automatic rollback on failures
- **ECS Exec**: Interactive debugging support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Service name | `string` | n/a | yes |
| cluster_id | ECS cluster ID | `string` | n/a | yes |
| task_definition_arn | Task definition ARN | `string` | n/a | yes |
| desired_count | Desired task count | `number` | `1` | no |
| launch_type | Launch type | `string` | `null` | no |
| platform_version | Fargate platform version | `string` | `"LATEST"` | no |
| scheduling_strategy | REPLICA or DAEMON | `string` | `"REPLICA"` | no |
| enable_execute_command | Enable ECS Exec | `bool` | `false` | no |
| capacity_provider_strategy | Capacity provider config | `list(object)` | `[]` | no |
| subnet_ids | Subnet IDs for awsvpc | `list(string)` | `[]` | no |
| security_group_ids | Security group IDs | `list(string)` | `[]` | no |
| assign_public_ip | Assign public IP | `bool` | `false` | no |
| load_balancers | Load balancer configs | `list(object)` | `[]` | no |
| health_check_grace_period_seconds | Health check grace period | `number` | `null` | no |
| deployment_minimum_healthy_percent | Min healthy percent | `number` | `100` | no |
| deployment_maximum_percent | Max percent | `number` | `200` | no |
| deployment_circuit_breaker | Circuit breaker config | `object` | `{enable=true}` | no |
| enable_autoscaling | Enable auto scaling | `bool` | `false` | no |
| autoscaling_min_capacity | Min capacity | `number` | `1` | no |
| autoscaling_max_capacity | Max capacity | `number` | `10` | no |
| autoscaling_policies | Scaling policies | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Service ID |
| name | Service name |
| cluster | Cluster ARN |
| desired_count | Desired task count |
| task_definition | Task definition ARN |
| autoscaling_target_id | Auto scaling target ID |
| autoscaling_policy_arns | Auto scaling policy ARNs |

## Auto Scaling Metrics

| Metric | Description |
|--------|-------------|
| ECSServiceAverageCPUUtilization | Average CPU utilization |
| ECSServiceAverageMemoryUtilization | Average memory utilization |
| ALBRequestCountPerTarget | Requests per target (requires ALB) |

## Considerations

- Fargate requires `awsvpc` network mode and subnet/security group configuration
- Load balancer health checks need grace period for slow-starting apps
- Circuit breaker prevents bad deployments from completing
- Auto scaling ignores `desired_count` changes after initial creation
- DAEMON scheduling runs one task per container instance (EC2 only)
