# SQS Queue Module

Creates an Amazon SQS queue with optional dead letter queue and access policies.

## Usage

### Standard Queue

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name = "order-processing"

  tags = {
    Environment = "production"
  }
}
```

### Standard Queue with DLQ

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name       = "order-processing"
  create_dlq = true

  visibility_timeout_seconds = 60
  max_receive_count          = 3

  tags = {
    Environment = "production"
  }
}
```

### FIFO Queue

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name                        = "order-processing"
  fifo_queue                  = true
  content_based_deduplication = true

  tags = {
    Environment = "production"
  }
}
```

### High Throughput FIFO Queue

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name                        = "events"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"

  tags = {
    Environment = "production"
  }
}
```

### Long Polling

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name                      = "notifications"
  receive_wait_time_seconds = 20  # Long polling (max 20 seconds)

  tags = {
    Environment = "production"
  }
}
```

### KMS Encryption

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name              = "sensitive-data"
  kms_master_key_id = module.kms_key.id

  kms_data_key_reuse_period_seconds = 600

  tags = {
    Environment = "production"
  }
}
```

### External Dead Letter Queue

```hcl
module "dlq" {
  source = "path/to/modules/sqs-queue"

  name                      = "processing-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = {
    Environment = "production"
  }
}

module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name                  = "processing"
  dead_letter_queue_arn = module.dlq.arn
  max_receive_count     = 5

  tags = {
    Environment = "production"
  }
}
```

### SNS Subscription

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name              = "notifications"
  create_sns_policy = true
  sns_topic_arns    = [module.sns_topic.arn]

  tags = {
    Environment = "production"
  }
}
```

### Delayed Messages

```hcl
module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name          = "delayed-processing"
  delay_seconds = 300  # 5 minute delay for all messages

  tags = {
    Environment = "production"
  }
}
```

### Custom Queue Policy

```hcl
data "aws_iam_policy_document" "queue_policy" {
  statement {
    sid    = "AllowAccountAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:root"]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
    ]

    resources = ["*"]
  }
}

module "sqs_queue" {
  source = "path/to/modules/sqs-queue"

  name   = "shared-queue"
  policy = data.aws_iam_policy_document.queue_policy.json

  tags = {
    Environment = "production"
  }
}
```

### Queue as DLQ (Redrive Allow Policy)

```hcl
module "dlq" {
  source = "path/to/modules/sqs-queue"

  name = "shared-dlq"

  redrive_allow_policy = {
    redrivePermission = "byQueue"
    sourceQueueArns   = [
      "arn:aws:sqs:us-east-1:123456789012:queue-1",
      "arn:aws:sqs:us-east-1:123456789012:queue-2",
    ]
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Standard Queues**: Best-effort ordering, at-least-once delivery
- **FIFO Queues**: Guaranteed ordering, exactly-once processing
- **Dead Letter Queues**: Handle failed messages
- **Encryption**: SQS-managed SSE or KMS
- **Long Polling**: Reduce empty responses and cost
- **Delay Queues**: Postpone message delivery
- **Access Policies**: SNS integration, cross-account access

## Message Settings

| Setting | Default | Range | Description |
|---------|---------|-------|-------------|
| `visibility_timeout_seconds` | 30 | 0-43200 | Time message is hidden after receive |
| `message_retention_seconds` | 345600 (4 days) | 60-1209600 | How long to keep messages |
| `max_message_size` | 262144 (256 KB) | 1024-262144 | Maximum message size |
| `delay_seconds` | 0 | 0-900 | Delay before message is available |
| `receive_wait_time_seconds` | 0 | 0-20 | Long polling wait time |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Queue name | `string` | n/a | yes |
| fifo_queue | Whether this is a FIFO queue | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication | `bool` | `false` | no |
| deduplication_scope | Deduplication scope for FIFO | `string` | `null` | no |
| fifo_throughput_limit | FIFO throughput limit | `string` | `null` | no |
| visibility_timeout_seconds | Visibility timeout | `number` | `30` | no |
| message_retention_seconds | Message retention period | `number` | `345600` | no |
| max_message_size | Maximum message size | `number` | `262144` | no |
| delay_seconds | Message delay | `number` | `0` | no |
| receive_wait_time_seconds | Long polling wait time | `number` | `0` | no |
| sqs_managed_sse_enabled | Enable SQS-managed SSE | `bool` | `true` | no |
| kms_master_key_id | KMS key ID for encryption | `string` | `null` | no |
| kms_data_key_reuse_period_seconds | KMS data key reuse period | `number` | `300` | no |
| dead_letter_queue_arn | External DLQ ARN | `string` | `null` | no |
| max_receive_count | Max receives before DLQ | `number` | `5` | no |
| create_dlq | Create a DLQ | `bool` | `false` | no |
| dlq_message_retention_seconds | DLQ message retention | `number` | `1209600` | no |
| redrive_allow_policy | Redrive allow policy | `object` | `null` | no |
| policy | Custom queue policy JSON | `string` | `null` | no |
| create_sns_policy | Create SNS access policy | `bool` | `false` | no |
| sns_topic_arns | SNS topics allowed to publish | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Queue URL |
| arn | Queue ARN |
| name | Queue name |
| url | Queue URL |
| dlq_id | DLQ URL |
| dlq_arn | DLQ ARN |
| dlq_name | DLQ name |
| dlq_url | DLQ URL |

## Considerations

- FIFO queue names must end with `.fifo` (added automatically)
- Visibility timeout should be longer than your processing time
- Use long polling to reduce costs and improve efficiency
- FIFO queues have lower throughput than standard queues
- Content-based deduplication uses SHA-256 hash of message body
- DLQ must be the same type (standard/FIFO) as the source queue
