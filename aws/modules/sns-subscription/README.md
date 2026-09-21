# SNS Subscription Module

Creates an Amazon SNS subscription with optional message filtering and dead letter queue.

## Usage

### SQS Subscription

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "sqs"
  endpoint  = module.sqs_queue.arn
}
```

### SQS with Raw Message Delivery

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn            = module.sns_topic.arn
  protocol             = "sqs"
  endpoint             = module.sqs_queue.arn
  raw_message_delivery = true
}
```

### Lambda Subscription

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn

  # Lambda permission created automatically
}
```

### Email Subscription

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "email"
  endpoint  = "alerts@example.com"

  # Requires manual confirmation via email
}
```

### Email JSON Subscription

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "email-json"
  endpoint  = "developer@example.com"

  # Full JSON message body in email
}
```

### SMS Subscription

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "sms"
  endpoint  = "+15551234567"
}
```

### HTTPS Webhook

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn                       = module.sns_topic.arn
  protocol                        = "https"
  endpoint                        = "https://api.example.com/webhooks/sns"
  confirmation_timeout_in_minutes = 5
}
```

### Message Filtering (Attribute-Based)

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "sqs"
  endpoint  = module.order_queue.arn

  filter_policy = jsonencode({
    event_type = ["order_created", "order_updated"]
    store_id   = [{ numeric = [">=", 100, "<", 200] }]
  })
}
```

### Message Filtering (Body-Based)

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "sqs"
  endpoint  = module.priority_queue.arn

  filter_policy_scope = "MessageBody"
  filter_policy = jsonencode({
    priority = ["high", "critical"]
  })
}
```

### With Dead Letter Queue

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn             = module.sns_topic.arn
  protocol              = "lambda"
  endpoint              = module.lambda.arn
  dead_letter_queue_arn = module.dlq.arn
}
```

### Custom Redrive Policy

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "sqs"
  endpoint  = module.sqs_queue.arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.dlq.arn
  })
}
```

### Kinesis Firehose Subscription

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn             = module.sns_topic.arn
  protocol              = "firehose"
  endpoint              = module.firehose.arn
  subscription_role_arn = aws_iam_role.sns_firehose.arn
}
```

### Custom Delivery Policy (HTTP/HTTPS)

```hcl
module "sns_subscription" {
  source = "path/to/modules/sns-subscription"

  topic_arn = module.sns_topic.arn
  protocol  = "https"
  endpoint  = "https://api.example.com/webhook"

  delivery_policy = jsonencode({
    healthyRetryPolicy = {
      minDelayTarget     = 10
      maxDelayTarget     = 30
      numRetries         = 5
      numNoDelayRetries  = 2
      backoffFunction    = "exponential"
    }
    throttlePolicy = {
      maxReceivesPerSecond = 10
    }
  })
}
```

### Multiple Subscriptions

```hcl
locals {
  subscriptions = {
    orders = {
      protocol = "sqs"
      endpoint = module.order_queue.arn
      filter   = { event_type = ["order_created"] }
    }
    notifications = {
      protocol = "lambda"
      endpoint = module.notification_lambda.arn
      filter   = { event_type = ["notification"] }
    }
    archive = {
      protocol = "sqs"
      endpoint = module.archive_queue.arn
      filter   = null  # Receive all messages
    }
  }
}

module "sns_subscriptions" {
  source   = "path/to/modules/sns-subscription"
  for_each = local.subscriptions

  topic_arn     = module.sns_topic.arn
  protocol      = each.value.protocol
  endpoint      = each.value.endpoint
  filter_policy = each.value.filter != null ? jsonencode(each.value.filter) : null
}
```

## Features

- **Multiple Protocols**: SQS, Lambda, HTTP/S, Email, SMS, Firehose
- **Message Filtering**: Filter by message attributes or body
- **Dead Letter Queue**: Handle failed deliveries
- **Raw Message Delivery**: Skip SNS message wrapping
- **Custom Delivery Policies**: Configure retry behavior
- **Auto Lambda Permission**: Creates invoke permission automatically

## Supported Protocols

| Protocol | Endpoint Type | Notes |
|----------|---------------|-------|
| `sqs` | SQS queue ARN | Supports raw delivery, filtering |
| `lambda` | Lambda function ARN | Auto-creates invoke permission |
| `http` | HTTP URL | Requires endpoint confirmation |
| `https` | HTTPS URL | Requires endpoint confirmation |
| `email` | Email address | Requires email confirmation |
| `email-json` | Email address | Full JSON in email body |
| `sms` | Phone number | E.164 format (+15551234567) |
| `application` | Platform endpoint ARN | Mobile push notifications |
| `firehose` | Firehose delivery stream ARN | Requires IAM role |

## Filter Policy Examples

### String Matching
```json
{
  "event_type": ["order_created", "order_updated"]
}
```

### Numeric Comparison
```json
{
  "price": [{ "numeric": [">=", 100] }]
}
```

### Prefix Matching
```json
{
  "customer_id": [{ "prefix": "us-" }]
}
```

### Exists Check
```json
{
  "metadata": [{ "exists": true }]
}
```

### Anything-But
```json
{
  "status": [{ "anything-but": ["deleted", "archived"] }]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| topic_arn | SNS topic ARN | `string` | n/a | yes |
| protocol | Subscription protocol | `string` | n/a | yes |
| endpoint | Subscription endpoint | `string` | n/a | yes |
| raw_message_delivery | Enable raw message delivery | `bool` | `false` | no |
| confirmation_timeout_in_minutes | HTTP/S confirmation timeout | `number` | `null` | no |
| delivery_policy | Delivery policy JSON | `string` | `null` | no |
| filter_policy | Filter policy JSON | `string` | `null` | no |
| filter_policy_scope | Filter scope (MessageAttributes/MessageBody) | `string` | `null` | no |
| redrive_policy | Redrive policy JSON | `string` | `null` | no |
| dead_letter_queue_arn | DLQ ARN (alternative to redrive_policy) | `string` | `null` | no |
| subscription_role_arn | IAM role for Firehose | `string` | `null` | no |
| create_lambda_permission | Create Lambda invoke permission | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Subscription ARN |
| arn | Subscription ARN |
| topic_arn | Topic ARN |
| protocol | Subscription protocol |
| endpoint | Subscription endpoint |
| confirmation_was_authenticated | Whether confirmation was authenticated |
| owner_id | Subscription owner account ID |
| pending_confirmation | Whether subscription is pending |

## Considerations

- Email and SMS subscriptions require manual confirmation
- HTTP/HTTPS endpoints must confirm the subscription programmatically
- FIFO topic subscriptions require FIFO SQS queues
- Raw message delivery is only supported for SQS, HTTP/S, and Firehose
- Filter policies can have up to 5 attribute names
- Each attribute can have up to 150 values
- DLQ must grant SNS permission to send messages
