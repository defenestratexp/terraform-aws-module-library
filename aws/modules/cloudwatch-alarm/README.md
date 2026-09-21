# CloudWatch Alarm Module

Creates Amazon CloudWatch metric alarms or composite alarms with configurable actions.

## Usage

### Basic Metric Alarm

```hcl
module "cpu_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "high-cpu-utilization"
  alarm_description   = "CPU utilization exceeded 80%"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### M of N Evaluation

```hcl
module "alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "api-errors"
  alarm_description   = "API errors exceeded threshold (3 of 5 periods)"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 5
  datapoints_to_alarm = 3  # 3 of 5 periods must breach
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    ApiName = "my-api"
  }

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Percentile Statistic

```hcl
module "latency_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "high-latency-p99"
  alarm_description   = "P99 latency exceeded 1 second"
  metric_name         = "Latency"
  namespace           = "AWS/ELB"
  extended_statistic  = "p99"
  period              = 300
  evaluation_periods  = 3
  threshold           = 1000
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancerName = "my-load-balancer"
  }

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Metric Math Expression

```hcl
module "error_rate_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "high-error-rate"
  alarm_description   = "Error rate exceeded 5%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 5

  metric_queries = [
    {
      id          = "e1"
      expression  = "(m2/m1)*100"
      label       = "Error Rate"
      return_data = true
    },
    {
      id          = "m1"
      return_data = false
      metric = {
        metric_name = "RequestCount"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = "app/my-alb/1234567890"
        }
      }
    },
    {
      id          = "m2"
      return_data = false
      metric = {
        metric_name = "HTTPCode_Target_5XX_Count"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = "app/my-alb/1234567890"
        }
      }
    }
  ]

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Anomaly Detection

```hcl
module "anomaly_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "cpu-anomaly"
  alarm_description   = "CPU utilization anomaly detected"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"

  metric_queries = [
    {
      id          = "m1"
      return_data = true
      metric = {
        metric_name = "CPUUtilization"
        namespace   = "AWS/EC2"
        period      = 300
        stat        = "Average"
        dimensions = {
          InstanceId = "i-1234567890abcdef0"
        }
      }
    },
    {
      id          = "ad1"
      expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
      label       = "Anomaly Detection Band"
      return_data = true
    }
  ]

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Multiple Actions

```hcl
module "critical_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "critical-error"
  metric_name         = "ErrorCount"
  namespace           = "MyApp"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  # Different actions for different states
  alarm_actions             = [module.pagerduty_topic.arn, module.slack_topic.arn]
  ok_actions                = [module.slack_topic.arn]
  insufficient_data_actions = [module.ops_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Composite Alarm

```hcl
module "composite_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name        = "service-health"
  alarm_description = "Service is unhealthy when CPU or memory alarms trigger"
  alarm_type        = "composite"

  alarm_rule = "ALARM(${module.cpu_alarm.alarm_name}) OR ALARM(${module.memory_alarm.alarm_name})"

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Composite Alarm with Actions Suppressor

```hcl
module "composite_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name        = "service-health-suppressed"
  alarm_description = "Service health with maintenance window suppression"
  alarm_type        = "composite"

  alarm_rule = "ALARM(${module.cpu_alarm.alarm_name}) OR ALARM(${module.memory_alarm.alarm_name})"

  # Suppress actions during maintenance
  actions_suppressor                  = module.maintenance_alarm.alarm_name
  actions_suppressor_wait_period      = 60
  actions_suppressor_extension_period = 60

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### EC2 Auto Recovery

```hcl
module "recovery_alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "ec2-status-check"
  alarm_description   = "Trigger EC2 recovery on status check failure"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }

  # EC2 recovery action
  alarm_actions = ["arn:aws:automate:us-east-1:ec2:recover"]

  tags = {
    Environment = "production"
  }
}
```

### Missing Data Handling

```hcl
module "alarm" {
  source = "path/to/modules/cloudwatch-alarm"

  alarm_name          = "queue-messages"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = 100
  comparison_operator = "GreaterThanThreshold"

  # Treat missing data as not breaching (queue might be empty)
  treat_missing_data = "notBreaching"

  dimensions = {
    QueueName = "my-queue"
  }

  alarm_actions = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Metric Alarms**: Monitor single metrics with thresholds
- **Metric Math**: Combine metrics with expressions
- **Anomaly Detection**: ML-based anomaly detection bands
- **Composite Alarms**: Combine multiple alarms with logic
- **Actions Suppressor**: Suppress alerts during maintenance
- **Multiple Actions**: Different actions for ALARM, OK, INSUFFICIENT_DATA

## Comparison Operators

| Operator | Description |
|----------|-------------|
| `GreaterThanThreshold` | > threshold |
| `GreaterThanOrEqualToThreshold` | >= threshold |
| `LessThanThreshold` | < threshold |
| `LessThanOrEqualToThreshold` | <= threshold |
| `LessThanLowerOrGreaterThanUpperThreshold` | Anomaly detection |
| `LessThanLowerThreshold` | Below anomaly band |
| `GreaterThanUpperThreshold` | Above anomaly band |

## Common Action ARNs

| Action | ARN Pattern |
|--------|-------------|
| SNS Topic | `arn:aws:sns:region:account:topic-name` |
| EC2 Recover | `arn:aws:automate:region:ec2:recover` |
| EC2 Stop | `arn:aws:automate:region:ec2:stop` |
| EC2 Terminate | `arn:aws:automate:region:ec2:terminate` |
| EC2 Reboot | `arn:aws:automate:region:ec2:reboot` |
| Auto Scaling | `arn:aws:autoscaling:region:account:scalingPolicy:...` |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alarm_name | Alarm name | `string` | n/a | yes |
| alarm_type | Alarm type (metric/composite) | `string` | `"metric"` | no |
| metric_name | Metric name | `string` | `null` | no |
| namespace | Metric namespace | `string` | `null` | no |
| comparison_operator | Comparison operator | `string` | `"GreaterThanThreshold"` | no |
| evaluation_periods | Number of periods | `number` | `1` | no |
| period | Period in seconds | `number` | `300` | no |
| statistic | Statistic type | `string` | `null` | no |
| extended_statistic | Extended statistic (percentile) | `string` | `null` | no |
| threshold | Alarm threshold | `number` | `null` | no |
| threshold_metric_id | Anomaly detection metric ID | `string` | `null` | no |
| dimensions | Metric dimensions | `map(string)` | `{}` | no |
| metric_queries | Metric queries for math | `list(object)` | `[]` | no |
| alarm_rule | Composite alarm rule | `string` | `null` | no |
| datapoints_to_alarm | M of N datapoints | `number` | `null` | no |
| treat_missing_data | Missing data treatment | `string` | `"missing"` | no |
| actions_enabled | Enable actions | `bool` | `true` | no |
| alarm_actions | ALARM state actions | `list(string)` | `[]` | no |
| ok_actions | OK state actions | `list(string)` | `[]` | no |
| insufficient_data_actions | INSUFFICIENT_DATA actions | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Alarm ID |
| arn | Alarm ARN |
| alarm_name | Alarm name |
| alarm_type | Alarm type |

## Considerations

- Metric alarms support up to 10 metric queries
- Composite alarms can reference up to 100 child alarms
- Period must be 10, 30, or a multiple of 60 seconds
- Extended statistics (percentiles) require sufficient data points
- EC2 recovery actions only work with specific instance types
- Anomaly detection models require training period
