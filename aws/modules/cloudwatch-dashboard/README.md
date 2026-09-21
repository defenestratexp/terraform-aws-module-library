# CloudWatch Dashboard Module

Creates an Amazon CloudWatch dashboard with customizable widgets.

## Usage

### Basic Dashboard with JSON Body

```hcl
module "dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "my-application"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "CPU Utilization"
          region = "us-east-1"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}
```

### Dashboard with Widget List

```hcl
module "dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "my-application"

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        title  = "CPU Utilization"
        region = "us-east-1"
        metrics = [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
        ]
        period = 300
        stat   = "Average"
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = {
        title  = "Memory Utilization"
        region = "us-east-1"
        metrics = [
          ["CWAgent", "mem_used_percent", "InstanceId", "i-1234567890abcdef0"]
        ]
        period = 300
        stat   = "Average"
      }
    }
  ]
}
```

### EC2 Monitoring Dashboard

```hcl
module "ec2_dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "ec2-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# EC2 Instance Monitoring"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 8
        height = 6
        properties = {
          title   = "CPU Utilization"
          region  = "us-east-1"
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0", { stat = "Average" }]
          ]
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 1
        width  = 8
        height = 6
        properties = {
          title   = "Network In/Out"
          region  = "us-east-1"
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/EC2", "NetworkIn", "InstanceId", "i-1234567890abcdef0", { stat = "Sum" }],
            [".", "NetworkOut", ".", ".", { stat = "Sum" }]
          ]
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 1
        width  = 8
        height = 6
        properties = {
          title   = "Disk I/O"
          region  = "us-east-1"
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/EC2", "DiskReadBytes", "InstanceId", "i-1234567890abcdef0", { stat = "Sum" }],
            [".", "DiskWriteBytes", ".", ".", { stat = "Sum" }]
          ]
          period = 300
        }
      }
    ]
  })
}
```

### ALB Dashboard

```hcl
module "alb_dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "alb-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Request Count"
          region  = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/my-alb/1234567890", { stat = "Sum" }]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Target Response Time"
          region  = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/my-alb/1234567890", { stat = "Average" }],
            ["...", { stat = "p99" }]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "HTTP Status Codes"
          region  = "us-east-1"
          view    = "timeSeries"
          stacked = true
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", "app/my-alb/1234567890", { stat = "Sum", color = "#2ca02c" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { stat = "Sum", color = "#ff7f0e" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { stat = "Sum", color = "#d62728" }]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Healthy Hosts"
          region  = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "targetgroup/my-tg/1234567890", "LoadBalancer", "app/my-alb/1234567890", { stat = "Average" }],
            [".", "UnHealthyHostCount", ".", ".", ".", ".", { stat = "Average" }]
          ]
          period = 60
        }
      }
    ]
  })
}
```

### Lambda Dashboard

```hcl
module "lambda_dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "lambda-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title   = "Invocations"
          region  = "us-east-1"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "my-function", { stat = "Sum" }]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          title   = "Duration"
          region  = "us-east-1"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", "my-function", { stat = "Average" }],
            ["...", { stat = "p99" }],
            ["...", { stat = "Maximum" }]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          title   = "Errors & Throttles"
          region  = "us-east-1"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", "my-function", { stat = "Sum", color = "#d62728" }],
            [".", "Throttles", ".", ".", { stat = "Sum", color = "#ff7f0e" }]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Concurrent Executions"
          region  = "us-east-1"
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "my-function", { stat = "Maximum" }]
          ]
          period = 60
        }
      }
    ]
  })
}
```

### RDS Dashboard

```hcl
module "rds_dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "rds-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "CPU & Memory"
          region  = "us-east-1"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "my-database", { stat = "Average" }],
            [".", "FreeableMemory", ".", ".", { stat = "Average", yAxis = "right" }]
          ]
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Connections"
          region  = "us-east-1"
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "my-database", { stat = "Average" }]
          ]
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Read/Write Latency"
          region  = "us-east-1"
          metrics = [
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "my-database", { stat = "Average" }],
            [".", "WriteLatency", ".", ".", { stat = "Average" }]
          ]
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "IOPS"
          region  = "us-east-1"
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "my-database", { stat = "Average" }],
            [".", "WriteIOPS", ".", ".", { stat = "Average" }]
          ]
          period = 300
        }
      }
    ]
  })
}
```

### Dashboard with Alarm Widget

```hcl
module "dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "alarm-status"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "alarm"
        x      = 0
        y      = 0
        width  = 24
        height = 4
        properties = {
          title  = "Alarm Status"
          alarms = [
            "arn:aws:cloudwatch:us-east-1:123456789012:alarm:high-cpu",
            "arn:aws:cloudwatch:us-east-1:123456789012:alarm:high-memory",
            "arn:aws:cloudwatch:us-east-1:123456789012:alarm:high-errors"
          ]
        }
      }
    ]
  })
}
```

### Dashboard with Log Widget

```hcl
module "dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "logs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "log"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          title  = "Error Logs"
          region = "us-east-1"
          query  = "SOURCE '/aws/lambda/my-function' | filter @message like /ERROR/ | sort @timestamp desc | limit 100"
        }
      }
    ]
  })
}
```

### Dynamic Dashboard from Variables

```hcl
locals {
  instances = ["i-1234567890abcdef0", "i-0987654321fedcba0"]
}

module "dashboard" {
  source = "path/to/modules/cloudwatch-dashboard"

  dashboard_name = "multi-instance"

  widgets = [
    for idx, instance_id in local.instances : {
      type   = "metric"
      x      = (idx % 2) * 12
      y      = floor(idx / 2) * 6
      width  = 12
      height = 6
      properties = {
        title   = "CPU - ${instance_id}"
        region  = "us-east-1"
        metrics = [
          ["AWS/EC2", "CPUUtilization", "InstanceId", instance_id, { stat = "Average" }]
        ]
        period = 300
      }
    }
  ]
}
```

## Features

- **Metric Widgets**: Time series graphs for CloudWatch metrics
- **Text Widgets**: Markdown text for headers and documentation
- **Alarm Widgets**: Display alarm states
- **Log Widgets**: Query CloudWatch Logs Insights
- **Flexible Layout**: Position widgets using x, y coordinates
- **Dynamic Dashboards**: Generate widgets from Terraform variables

## Widget Types

| Type | Description |
|------|-------------|
| `metric` | Time series or number widget for metrics |
| `text` | Markdown text widget |
| `alarm` | Alarm status widget |
| `log` | CloudWatch Logs Insights query widget |
| `explorer` | Metrics Explorer widget |

## Dashboard Grid

- Dashboard width is 24 units
- Widget positions are specified with x, y coordinates
- Width and height are in grid units
- Minimum widget height is 1

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dashboard_name | Dashboard name | `string` | n/a | yes |
| dashboard_body | Dashboard JSON body | `string` | `null` | no |
| widgets | List of widget configs | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Dashboard name |
| arn | Dashboard ARN |
| name | Dashboard name |

## Considerations

- Use `jsonencode()` for dashboard_body to ensure valid JSON
- Dashboard names must be unique within an account
- Widgets can overlap - later widgets render on top
- Cross-account dashboards require appropriate permissions
- Consider using variables for dynamic dashboard generation
