# DynamoDB Table Module

Creates a DynamoDB table with support for GSIs, LSIs, streams, TTL, encryption, and autoscaling.

## Usage

### Basic Table (On-Demand)

```hcl
module "users_table" {
  source = "path/to/modules/dynamodb-table"

  name     = "users"
  hash_key = "user_id"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Table with Sort Key

```hcl
module "orders_table" {
  source = "path/to/modules/dynamodb-table"

  name      = "orders"
  hash_key  = "customer_id"
  range_key = "order_id"

  attributes = [
    {
      name = "customer_id"
      type = "S"
    },
    {
      name = "order_id"
      type = "S"
    }
  ]
}
```

### Table with Global Secondary Index

```hcl
module "products_table" {
  source = "path/to/modules/dynamodb-table"

  name     = "products"
  hash_key = "product_id"

  attributes = [
    {
      name = "product_id"
      type = "S"
    },
    {
      name = "category"
      type = "S"
    },
    {
      name = "price"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "category-price-index"
      hash_key        = "category"
      range_key       = "price"
      projection_type = "ALL"
    }
  ]
}
```

### Table with Local Secondary Index

```hcl
module "posts_table" {
  source = "path/to/modules/dynamodb-table"

  name      = "posts"
  hash_key  = "user_id"
  range_key = "post_id"

  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "post_id"
      type = "S"
    },
    {
      name = "created_at"
      type = "N"
    }
  ]

  local_secondary_indexes = [
    {
      name            = "created-at-index"
      range_key       = "created_at"
      projection_type = "ALL"
    }
  ]
}
```

### Provisioned Capacity with Autoscaling

```hcl
module "sessions_table" {
  source = "path/to/modules/dynamodb-table"

  name         = "sessions"
  hash_key     = "session_id"
  billing_mode = "PROVISIONED"

  read_capacity  = 10
  write_capacity = 10

  autoscaling_enabled = true

  autoscaling_read = {
    target_value = 70
    min_capacity = 10
    max_capacity = 1000
  }

  autoscaling_write = {
    target_value = 70
    min_capacity = 10
    max_capacity = 500
  }
}
```

### Table with TTL and Streams

```hcl
module "cache_table" {
  source = "path/to/modules/dynamodb-table"

  name     = "cache"
  hash_key = "cache_key"

  ttl_enabled        = true
  ttl_attribute_name = "expires_at"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}
```

### Production Table with All Features

```hcl
module "events_table" {
  source = "path/to/modules/dynamodb-table"

  name      = "events"
  hash_key  = "event_id"
  range_key = "timestamp"

  attributes = [
    {
      name = "event_id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    },
    {
      name = "event_type"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "event-type-index"
      hash_key        = "event_type"
      range_key       = "timestamp"
      projection_type = "ALL"
    }
  ]

  # Encryption
  server_side_encryption_enabled = true

  # Point-in-time recovery
  point_in_time_recovery_enabled = true

  # Deletion protection
  deletion_protection_enabled = true

  tags = {
    Environment = "production"
    Critical    = "true"
  }
}
```

### Global Table (Multi-Region)

```hcl
module "global_users_table" {
  source = "path/to/modules/dynamodb-table"

  name     = "global-users"
  hash_key = "user_id"

  stream_enabled   = true  # Required for global tables
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica_regions = ["us-west-2", "eu-west-1"]
}
```

## Features

- **Billing Modes**: On-demand (PAY_PER_REQUEST) or provisioned capacity
- **Global Secondary Indexes**: Support for GSIs with flexible projections
- **Local Secondary Indexes**: Support for LSIs
- **TTL**: Time-to-live configuration
- **Streams**: DynamoDB Streams for change data capture
- **Encryption**: Server-side encryption with AWS-managed or customer-managed KMS keys
- **Point-in-Time Recovery**: Continuous backups
- **Global Tables**: Multi-region replication
- **Autoscaling**: Read and write capacity autoscaling for provisioned mode
- **Table Class**: Standard or Infrequent Access

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the DynamoDB table | `string` | n/a | yes |
| hash_key | Attribute for hash (partition) key | `string` | n/a | yes |
| range_key | Attribute for range (sort) key | `string` | `""` | no |
| attributes | List of attribute definitions | `list(object)` | `[]` | no |
| billing_mode | Billing mode (PROVISIONED or PAY_PER_REQUEST) | `string` | `"PAY_PER_REQUEST"` | no |
| read_capacity | Read capacity units (PROVISIONED mode) | `number` | `5` | no |
| write_capacity | Write capacity units (PROVISIONED mode) | `number` | `5` | no |
| global_secondary_indexes | List of GSI configurations | `list(object)` | `[]` | no |
| local_secondary_indexes | List of LSI configurations | `list(object)` | `[]` | no |
| ttl_enabled | Enable TTL | `bool` | `false` | no |
| ttl_attribute_name | TTL attribute name | `string` | `"ttl"` | no |
| stream_enabled | Enable DynamoDB Streams | `bool` | `false` | no |
| stream_view_type | Stream view type | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| server_side_encryption_enabled | Enable encryption | `bool` | `true` | no |
| server_side_encryption_kms_key_arn | KMS key for encryption | `string` | `""` | no |
| point_in_time_recovery_enabled | Enable PITR | `bool` | `false` | no |
| replica_regions | Regions for global table replicas | `list(string)` | `[]` | no |
| table_class | Table class | `string` | `"STANDARD"` | no |
| deletion_protection_enabled | Enable deletion protection | `bool` | `false` | no |
| autoscaling_enabled | Enable autoscaling | `bool` | `false` | no |
| autoscaling_read | Read autoscaling configuration | `object` | `{}` | no |
| autoscaling_write | Write autoscaling configuration | `object` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The name of the table |
| arn | The ARN of the table |
| name | The name of the table |
| hash_key | The hash key of the table |
| range_key | The range key of the table |
| stream_arn | The ARN of the DynamoDB stream |
| stream_label | The timestamp of the stream |
| global_secondary_index_names | List of GSI names |
| local_secondary_index_names | List of LSI names |
| replica_arns | Map of replica region to ARN |

## Attribute Types

| Type | Description |
|------|-------------|
| S | String |
| N | Number |
| B | Binary |

## Stream View Types

| Type | Description |
|------|-------------|
| KEYS_ONLY | Only the key attributes |
| NEW_IMAGE | The entire item after modification |
| OLD_IMAGE | The entire item before modification |
| NEW_AND_OLD_IMAGES | Both old and new images |
