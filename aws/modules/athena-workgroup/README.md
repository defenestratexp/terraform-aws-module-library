# Athena Workgroup Module

Creates an Amazon Athena workgroup with query result configuration and optional named queries.

## Usage

### Basic Workgroup

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "analytics"
  output_location = "s3://my-athena-results/analytics/"

  tags = {
    Environment = "production"
  }
}
```

### With SSE-S3 Encryption

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "analytics"
  output_location = "s3://my-athena-results/analytics/"

  encryption_configuration = {
    encryption_option = "SSE_S3"
  }

  tags = {
    Environment = "production"
  }
}
```

### With KMS Encryption

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "secure-analytics"
  output_location = "s3://my-athena-results/secure/"

  encryption_configuration = {
    encryption_option = "SSE_KMS"
    kms_key_arn       = module.kms_key.arn
  }

  tags = {
    Environment = "production"
  }
}
```

### With Query Limits

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "limited-analytics"
  output_location = "s3://my-athena-results/limited/"

  # Limit to 10 GB scanned per query
  bytes_scanned_cutoff_per_query = 10737418240

  tags = {
    Environment = "production"
  }
}
```

### With Specific Engine Version

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "analytics-v3"
  output_location = "s3://my-athena-results/v3/"

  engine_version = {
    selected_engine_version = "Athena engine version 3"
  }

  tags = {
    Environment = "production"
  }
}
```

### With Named Queries

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "analytics"
  output_location = "s3://my-athena-results/analytics/"

  named_queries = {
    daily_orders = {
      description = "Count of orders by day"
      database    = "sales"
      query       = <<-EOT
        SELECT DATE(created_at) as order_date, COUNT(*) as order_count
        FROM orders
        WHERE created_at >= DATE_ADD('day', -30, CURRENT_DATE)
        GROUP BY DATE(created_at)
        ORDER BY order_date DESC
      EOT
    }
    top_customers = {
      description = "Top 10 customers by revenue"
      database    = "sales"
      query       = <<-EOT
        SELECT customer_id, SUM(total_amount) as revenue
        FROM orders
        GROUP BY customer_id
        ORDER BY revenue DESC
        LIMIT 10
      EOT
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Enforced Configuration

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "compliant-analytics"
  output_location = "s3://my-athena-results/compliant/"

  # Force all queries to use workgroup settings
  enforce_workgroup_configuration = true

  encryption_configuration = {
    encryption_option = "SSE_KMS"
    kms_key_arn       = module.kms_key.arn
  }

  # Limit scans to 100 GB
  bytes_scanned_cutoff_per_query = 107374182400

  tags = {
    Environment = "production"
  }
}
```

### With CloudWatch Metrics Disabled

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "dev-analytics"
  output_location = "s3://my-athena-results/dev/"

  publish_cloudwatch_metrics_enabled = false

  tags = {
    Environment = "development"
  }
}
```

### With Requester Pays

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "cross-account"
  output_location = "s3://my-athena-results/cross-account/"

  requester_pays_enabled = true

  tags = {
    Environment = "production"
  }
}
```

### Disabled Workgroup

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "maintenance"
  output_location = "s3://my-athena-results/maintenance/"
  state           = "DISABLED"

  tags = {
    Environment = "production"
  }
}
```

### With Execution Role (Athena v3)

```hcl
module "athena_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "role-based"
  output_location = "s3://my-athena-results/role-based/"
  execution_role  = aws_iam_role.athena_execution.arn

  engine_version = {
    selected_engine_version = "Athena engine version 3"
  }

  tags = {
    Environment = "production"
  }
}
```

### Development vs Production

```hcl
# Development - flexible
module "dev_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "dev"
  output_location = "s3://athena-results-dev/"

  enforce_workgroup_configuration = false
  force_destroy                   = true

  bytes_scanned_cutoff_per_query = 1073741824  # 1 GB

  tags = {
    Environment = "development"
  }
}

# Production - strict
module "prod_workgroup" {
  source = "path/to/modules/athena-workgroup"

  name            = "prod"
  output_location = "s3://athena-results-prod/"

  enforce_workgroup_configuration = true
  force_destroy                   = false

  encryption_configuration = {
    encryption_option = "SSE_KMS"
    kms_key_arn       = module.kms_key.arn
  }

  bytes_scanned_cutoff_per_query = 107374182400  # 100 GB

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Query Results**: Configure S3 output location and encryption
- **Cost Control**: Set bytes scanned limits per query
- **Engine Versions**: Select Athena engine version (v2, v3)
- **Named Queries**: Save commonly used queries
- **CloudWatch Integration**: Publish query metrics
- **Configuration Enforcement**: Override client-side settings

## Encryption Options

| Option | Description |
|--------|-------------|
| `SSE_S3` | Server-side encryption with S3-managed keys |
| `SSE_KMS` | Server-side encryption with KMS-managed keys |
| `CSE_KMS` | Client-side encryption with KMS-managed keys |

## Engine Versions

| Version | Features |
|---------|----------|
| Athena engine version 2 | Based on Presto 0.217 |
| Athena engine version 3 | Based on Trino, better performance |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Workgroup name | `string` | n/a | yes |
| description | Workgroup description | `string` | `null` | no |
| state | Workgroup state | `string` | `"ENABLED"` | no |
| force_destroy | Force destroy with queries | `bool` | `false` | no |
| output_location | S3 output location | `string` | `null` | no |
| encryption_configuration | Encryption settings | `object` | `null` | no |
| bytes_scanned_cutoff_per_query | Max bytes per query | `number` | `null` | no |
| execution_role | IAM role for execution | `string` | `null` | no |
| engine_version | Engine version | `object` | `null` | no |
| publish_cloudwatch_metrics_enabled | Publish metrics | `bool` | `true` | no |
| requester_pays_enabled | Allow requester pays | `bool` | `false` | no |
| enforce_workgroup_configuration | Enforce config | `bool` | `true` | no |
| named_queries | Map of named queries | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Workgroup name |
| arn | Workgroup ARN |
| name | Workgroup name |
| state | Workgroup state |
| named_query_ids | Map of named query IDs |

## Considerations

- Workgroup names must be unique per region
- Results location must be an S3 path ending with `/`
- KMS encryption requires key access permissions
- Bytes scanned limit cancels queries that exceed the threshold
- Engine version 3 provides better performance but may have breaking changes
- Named queries are saved but not automatically executed
