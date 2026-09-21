# CloudWatch Log Group Module

Creates an Amazon CloudWatch log group with optional metric filters and subscription filters.

## Usage

### Basic Log Group

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/my-application"
  retention_in_days = 30

  tags = {
    Environment = "production"
  }
}
```

### Log Group with KMS Encryption

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/secure-application"
  retention_in_days = 90
  kms_key_id        = module.kms_key.arn

  tags = {
    Environment = "production"
  }
}
```

### Infrequent Access Log Group

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/archive-logs"
  retention_in_days = 365
  log_group_class   = "INFREQUENT_ACCESS"

  tags = {
    Environment = "production"
  }
}
```

### Never Expire Logs

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/compliance/audit-logs"
  retention_in_days = 0  # Never expire
  skip_destroy      = true

  tags = {
    Environment = "production"
  }
}
```

### With Metric Filters

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/web-server"
  retention_in_days = 30

  metric_filters = {
    errors = {
      pattern          = "[timestamp, level=ERROR, ...]"
      metric_name      = "ErrorCount"
      metric_namespace = "MyApp"
      metric_value     = "1"
    }
    latency = {
      pattern          = "[timestamp, level, message, latency]"
      metric_name      = "RequestLatency"
      metric_namespace = "MyApp"
      metric_value     = "$latency"
      unit             = "Milliseconds"
    }
    status_codes = {
      pattern          = "{ $.statusCode = 5* }"
      metric_name      = "5xxErrors"
      metric_namespace = "MyApp"
      metric_value     = "1"
      default_value    = "0"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### With Lambda Subscription

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/events"
  retention_in_days = 7

  subscription_filters = {
    lambda_processor = {
      destination_arn = module.processor_lambda.arn
      filter_pattern  = "{ $.level = \"ERROR\" }"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### With Kinesis Subscription

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/streaming"
  retention_in_days = 14

  subscription_filters = {
    kinesis_stream = {
      destination_arn = module.kinesis_stream.arn
      role_arn        = aws_iam_role.cwl_kinesis.arn
      filter_pattern  = ""  # All logs
      distribution    = "ByLogStream"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### With Kinesis Firehose Subscription

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/analytics"
  retention_in_days = 30

  subscription_filters = {
    firehose = {
      destination_arn = module.firehose.arn
      role_arn        = aws_iam_role.cwl_firehose.arn
      filter_pattern  = ""
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Multiple Subscription Filters

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/multi-destination"
  retention_in_days = 30

  subscription_filters = {
    errors_to_lambda = {
      destination_arn = module.error_handler.arn
      filter_pattern  = "{ $.level = \"ERROR\" }"
    }
    all_to_s3 = {
      destination_arn = module.firehose_to_s3.arn
      role_arn        = aws_iam_role.cwl_firehose.arn
      filter_pattern  = ""
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Combined Metric and Subscription Filters

```hcl
module "log_group" {
  source = "path/to/modules/cloudwatch-log-group"

  name              = "/app/monitored"
  retention_in_days = 30

  metric_filters = {
    error_count = {
      pattern          = "{ $.level = \"ERROR\" }"
      metric_name      = "ErrorCount"
      metric_namespace = "MyApp/Errors"
      metric_value     = "1"
    }
  }

  subscription_filters = {
    alerts = {
      destination_arn = module.alert_lambda.arn
      filter_pattern  = "{ $.level = \"CRITICAL\" }"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Retention Policies**: Configure log retention from 1 day to 10 years
- **Encryption**: KMS encryption for logs at rest
- **Log Classes**: Standard or Infrequent Access for cost optimization
- **Metric Filters**: Create CloudWatch metrics from log patterns
- **Subscription Filters**: Stream logs to Lambda, Kinesis, or Firehose
- **Skip Destroy**: Prevent accidental deletion of important logs

## Filter Pattern Syntax

### JSON Patterns
```
{ $.level = "ERROR" }
{ $.statusCode >= 400 }
{ $.duration > 1000 }
{ $.user.id EXISTS }
```

### Space-Delimited Patterns
```
[timestamp, level=ERROR, ...]
[ip, user, timestamp, request, status_code=5*, bytes]
```

### Text Patterns
```
ERROR
"Out of memory"
?ERROR ?WARN
```

## Valid Retention Values

| Days | Description |
|------|-------------|
| 0 | Never expire |
| 1, 3, 5, 7, 14, 30 | Short-term |
| 60, 90, 120, 150, 180 | Medium-term |
| 365, 400, 545 | ~1-1.5 years |
| 731, 1096, 1827 | ~2-5 years |
| 2192, 2557, 2922, 3288, 3653 | ~6-10 years |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Log group name | `string` | n/a | yes |
| retention_in_days | Log retention in days | `number` | `30` | no |
| kms_key_id | KMS key ARN for encryption | `string` | `null` | no |
| log_group_class | Log group class | `string` | `"STANDARD"` | no |
| skip_destroy | Prevent accidental deletion | `bool` | `false` | no |
| metric_filters | Map of metric filters | `map(object)` | `{}` | no |
| subscription_filters | Map of subscription filters | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Log group name |
| arn | Log group ARN |
| name | Log group name |
| metric_filter_ids | Map of metric filter IDs |
| subscription_filter_ids | Map of subscription filter IDs |

## Considerations

- Subscription filter destinations need appropriate permissions
- Lambda destinations need invoke permission for CloudWatch Logs
- Kinesis/Firehose destinations need IAM role with put permissions
- Maximum 2 subscription filters per log group
- Infrequent Access class has lower storage cost but higher retrieval cost
- KMS key must grant CloudWatch Logs service access
