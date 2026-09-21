# Kinesis Stream Module

Creates an Amazon Kinesis Data Stream with optional enhanced fan-out consumers.

## Usage

### On-Demand Stream (Recommended)

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name = "my-data-stream"

  tags = {
    Environment = "production"
  }
}
```

### Provisioned Stream

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name        = "my-data-stream"
  stream_mode = "PROVISIONED"
  shard_count = 4

  tags = {
    Environment = "production"
  }
}
```

### Extended Retention

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name             = "my-data-stream"
  retention_period = 168  # 7 days

  tags = {
    Environment = "production"
  }
}
```

### Long-Term Retention

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name             = "compliance-stream"
  retention_period = 8760  # 365 days (maximum)

  tags = {
    Environment = "production"
  }
}
```

### With Custom KMS Key

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name           = "secure-stream"
  encryption_type = "KMS"
  kms_key_id     = module.kms_key.arn

  tags = {
    Environment = "production"
  }
}
```

### Without Encryption

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name            = "dev-stream"
  encryption_type = "NONE"

  tags = {
    Environment = "development"
  }
}
```

### With Enhanced Fan-Out Consumers

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name = "shared-stream"

  consumers = {
    lambda = {
      name = "lambda-consumer"
    }
    analytics = {
      name = "analytics-consumer"
    }
    archive = {
      name = "archive-consumer"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### High-Throughput Stream

```hcl
module "kinesis_stream" {
  source = "path/to/modules/kinesis-stream"

  name        = "high-volume-stream"
  stream_mode = "PROVISIONED"
  shard_count = 64

  retention_period = 48  # 2 days

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Stream Modes**: On-demand (auto-scaling) or provisioned (fixed capacity)
- **Retention**: 24 hours to 365 days
- **Encryption**: AWS-managed or customer-managed KMS keys
- **Enhanced Fan-Out**: Dedicated throughput per consumer
- **Scaling**: Automatic (on-demand) or manual shard management

## Stream Mode Comparison

| Feature | On-Demand | Provisioned |
|---------|-----------|-------------|
| Scaling | Automatic | Manual |
| Pricing | Per GB | Per shard-hour |
| Throughput | Auto-scales | Fixed per shard |
| Best for | Variable workloads | Predictable workloads |

## Capacity Limits

### Per Shard (Provisioned Mode)
- **Write**: 1 MB/sec or 1,000 records/sec
- **Read**: 2 MB/sec (shared) or 2 MB/sec per consumer (enhanced)

### On-Demand Mode
- **Write**: Up to 200 MB/sec
- **Read**: Up to 400 MB/sec
- Auto-scales based on throughput

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Stream name | `string` | n/a | yes |
| stream_mode | Stream mode (PROVISIONED/ON_DEMAND) | `string` | `"ON_DEMAND"` | no |
| shard_count | Number of shards (provisioned mode) | `number` | `null` | no |
| retention_period | Retention period in hours (24-8760) | `number` | `24` | no |
| encryption_type | Encryption type (NONE/KMS) | `string` | `"KMS"` | no |
| kms_key_id | KMS key ID for encryption | `string` | `"alias/aws/kinesis"` | no |
| consumers | Map of enhanced fan-out consumers | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Stream ID |
| arn | Stream ARN |
| name | Stream name |
| shard_count | Number of shards |
| stream_mode | Stream mode |
| retention_period | Retention period in hours |
| consumer_arns | Map of consumer ARNs |
| consumer_ids | Map of consumer IDs |

## Considerations

- On-demand mode is recommended for most use cases
- Provisioned mode requires manual shard splitting/merging for scaling
- Enhanced fan-out provides dedicated 2 MB/sec per consumer
- Retention beyond 24 hours incurs additional storage costs
- Extended retention (>7 days) has higher per-GB pricing
- Encryption is enabled by default with AWS-managed key
- Shard count changes require time to complete
