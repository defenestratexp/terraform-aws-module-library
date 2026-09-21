# EventBridge Rule Module

Creates an Amazon EventBridge rule with targets for event-driven architectures.

## Usage

### Scheduled Lambda Invocation

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name                = "daily-cleanup"
  description         = "Run cleanup Lambda daily"
  schedule_expression = "cron(0 2 * * ? *)"  # 2 AM UTC daily

  targets = {
    cleanup = {
      arn = module.cleanup_lambda.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Rate-Based Schedule

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name                = "health-check"
  schedule_expression = "rate(5 minutes)"

  targets = {
    checker = {
      arn = module.health_check_lambda.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Event Pattern Matching

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name        = "ec2-state-change"
  description = "React to EC2 instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running", "stopped", "terminated"]
    }
  })

  targets = {
    handler = {
      arn = module.ec2_handler_lambda.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### S3 Event Pattern

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name = "s3-upload-handler"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["my-bucket"]
      }
      object = {
        key = [{
          prefix = "uploads/"
        }]
      }
    }
  })

  targets = {
    processor = {
      arn = module.processor_lambda.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Multiple Targets

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name                = "order-created"
  schedule_expression = "rate(1 minute)"

  targets = {
    lambda = {
      arn = module.order_lambda.arn
    }
    sqs = {
      arn = module.order_queue.arn
    }
    sns = {
      arn = module.notification_topic.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Input Transformation

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name = "transformed-event"

  event_pattern = jsonencode({
    source = ["custom.app"]
  })

  targets = {
    handler = {
      arn = module.lambda.arn
      input_transformer = {
        input_paths = {
          instance  = "$.detail.instance-id"
          status    = "$.detail.status"
          timestamp = "$.time"
        }
        input_template = <<EOF
{
  "instanceId": "<instance>",
  "currentStatus": "<status>",
  "eventTime": "<timestamp>",
  "source": "eventbridge"
}
EOF
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### ECS Task Target

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name                = "scheduled-task"
  schedule_expression = "rate(1 hour)"

  targets = {
    ecs_task = {
      arn      = module.ecs_cluster.arn
      role_arn = aws_iam_role.eventbridge_ecs.arn
      ecs_target = {
        task_definition_arn = module.task_definition.arn
        task_count          = 1
        launch_type         = "FARGATE"
        network_configuration = {
          subnets          = module.vpc.private_subnet_ids
          security_groups  = [module.task_sg.id]
          assign_public_ip = false
        }
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Step Functions Target

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name = "trigger-workflow"

  event_pattern = jsonencode({
    source      = ["custom.orders"]
    detail-type = ["Order Created"]
  })

  targets = {
    workflow = {
      arn      = module.state_machine.arn
      role_arn = aws_iam_role.eventbridge_sfn.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Dead Letter Queue

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name                = "reliable-trigger"
  schedule_expression = "rate(5 minutes)"

  targets = {
    handler = {
      arn = module.lambda.arn
      retry_policy = {
        maximum_event_age_in_seconds = 3600
        maximum_retry_attempts       = 3
      }
      dead_letter_config = {
        arn = module.dlq.arn
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Custom Event Bus

```hcl
resource "aws_cloudwatch_event_bus" "custom" {
  name = "custom-events"
}

module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name           = "custom-bus-rule"
  event_bus_name = aws_cloudwatch_event_bus.custom.name

  event_pattern = jsonencode({
    source = ["custom.app"]
  })

  targets = {
    handler = {
      arn = module.lambda.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Disabled Rule

```hcl
module "eventbridge_rule" {
  source = "path/to/modules/eventbridge-rule"

  name                = "maintenance-job"
  schedule_expression = "rate(1 day)"
  is_enabled          = false  # Disabled

  targets = {
    maintenance = {
      arn = module.maintenance_lambda.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Schedule-Based**: Cron and rate expressions
- **Event Patterns**: Match specific events
- **Multiple Targets**: Route to Lambda, SQS, SNS, ECS, Step Functions
- **Input Transformation**: Transform event data before delivery
- **Retry Policies**: Configure retry behavior
- **Dead Letter Queues**: Handle failed deliveries
- **Custom Event Buses**: Organize events by application

## Schedule Expressions

### Cron Expressions
```
cron(minutes hours day-of-month month day-of-week year)

Examples:
- cron(0 12 * * ? *)        # Daily at 12:00 PM UTC
- cron(0 8 ? * MON-FRI *)   # Weekdays at 8:00 AM UTC
- cron(0/15 * * * ? *)      # Every 15 minutes
```

### Rate Expressions
```
rate(value unit)

Examples:
- rate(1 minute)
- rate(5 minutes)
- rate(1 hour)
- rate(1 day)
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Rule name | `string` | n/a | yes |
| description | Rule description | `string` | `""` | no |
| event_bus_name | Event bus name | `string` | `"default"` | no |
| schedule_expression | Schedule expression | `string` | `null` | no |
| event_pattern | Event pattern JSON | `string` | `null` | no |
| is_enabled | Enable the rule | `bool` | `true` | no |
| targets | Target configurations | `map(object)` | `{}` | no |
| create_lambda_permissions | Create Lambda permissions | `bool` | `true` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Rule ID |
| arn | Rule ARN |
| name | Rule name |
| event_bus_name | Event bus name |
| target_ids | Map of target IDs |
| target_arns | Map of target ARNs |

## Considerations

- Use schedule expressions OR event patterns, not both
- Lambda permissions are created automatically by default
- ECS and Step Functions targets require an IAM role
- Dead letter queues need appropriate permissions
- Event pattern matching is case-sensitive
