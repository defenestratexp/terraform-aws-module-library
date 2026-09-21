# SNS Topic Module

Creates an Amazon SNS topic with access policies and delivery configuration.

## Usage

### Standard Topic

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name = "notifications"

  tags = {
    Environment = "production"
  }
}
```

### Topic with Display Name (for SMS)

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name         = "alerts"
  display_name = "MyApp Alerts"

  tags = {
    Environment = "production"
  }
}
```

### FIFO Topic

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name                        = "order-events"
  fifo_topic                  = true
  content_based_deduplication = true

  tags = {
    Environment = "production"
  }
}
```

### KMS Encryption

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name              = "secure-notifications"
  kms_master_key_id = module.kms_key.id

  tags = {
    Environment = "production"
  }
}
```

### EventBridge Integration

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name                      = "event-notifications"
  create_eventbridge_policy = true
  eventbridge_rule_arns     = [module.eventbridge_rule.arn]

  tags = {
    Environment = "production"
  }
}
```

### S3 Event Notifications

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name             = "s3-notifications"
  create_s3_policy = true
  s3_bucket_arns   = ["arn:aws:s3:::my-bucket"]

  tags = {
    Environment = "production"
  }
}
```

### Cross-Account Publishing

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name                   = "shared-notifications"
  create_publish_policy  = true
  publish_principal_arns = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::987654321098:role/publisher",
  ]

  tags = {
    Environment = "production"
  }
}
```

### Delivery Status Logging

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name = "logged-notifications"

  # Lambda delivery logging
  lambda_success_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  lambda_success_feedback_sample_rate = 100
  lambda_failure_feedback_role_arn    = aws_iam_role.sns_feedback.arn

  # SQS delivery logging
  sqs_success_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  sqs_success_feedback_sample_rate = 100
  sqs_failure_feedback_role_arn    = aws_iam_role.sns_feedback.arn

  tags = {
    Environment = "production"
  }
}
```

### Custom Topic Policy

```hcl
data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid    = "AllowPublish"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sns:Publish"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["o-xxxxxxxxxx"]
    }
  }
}

module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name   = "org-notifications"
  policy = data.aws_iam_policy_document.topic_policy.json

  tags = {
    Environment = "production"
  }
}
```

### Data Protection Policy

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name = "pii-notifications"

  data_protection_policy = jsonencode({
    Name        = "__default_policy"
    Description = "Default data protection policy"
    Version     = "2021-06-01"
    Statement = [{
      DataDirection = "Inbound"
      Principal     = ["*"]
      DataIdentifier = [
        "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber"
      ]
      Operation = {
        Deny = {}
      }
    }]
  })

  tags = {
    Environment = "production"
  }
}
```

### Custom Delivery Policy

```hcl
module "sns_topic" {
  source = "path/to/modules/sns-topic"

  name = "reliable-notifications"

  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        minDelayTarget     = 20
        maxDelayTarget     = 20
        numRetries         = 3
        numMaxDelayRetries = 0
        numNoDelayRetries  = 0
        numMinDelayRetries = 0
        backoffFunction    = "linear"
      }
      disableSubscriptionOverrides = false
    }
  })

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Standard Topics**: Multiple subscribers, fanout pattern
- **FIFO Topics**: Ordered message delivery with deduplication
- **Encryption**: KMS encryption for messages at rest
- **Access Policies**: Fine-grained publish/subscribe permissions
- **Delivery Logging**: CloudWatch logs for delivery status
- **Data Protection**: Block sensitive data patterns
- **AWS Service Integration**: EventBridge, S3, CloudWatch

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Topic name | `string` | n/a | yes |
| fifo_topic | Whether this is a FIFO topic | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication | `bool` | `false` | no |
| display_name | Display name for SMS | `string` | `null` | no |
| kms_master_key_id | KMS key ID for encryption | `string` | `null` | no |
| delivery_policy | Delivery policy JSON | `string` | `null` | no |
| policy | Custom topic policy JSON | `string` | `null` | no |
| create_publish_policy | Create publish policy | `bool` | `false` | no |
| publish_principal_arns | Principals allowed to publish | `list(string)` | `[]` | no |
| create_eventbridge_policy | Allow EventBridge to publish | `bool` | `false` | no |
| eventbridge_rule_arns | EventBridge rules allowed | `list(string)` | `[]` | no |
| create_s3_policy | Allow S3 to publish | `bool` | `false` | no |
| s3_bucket_arns | S3 buckets allowed | `list(string)` | `[]` | no |
| data_protection_policy | Data protection policy JSON | `string` | `null` | no |
| archive_policy | Archive policy for FIFO topics | `string` | `null` | no |
| *_success_feedback_role_arn | IAM role for delivery logging | `string` | `null` | no |
| *_success_feedback_sample_rate | Sample rate (0-100) | `number` | `null` | no |
| *_failure_feedback_role_arn | IAM role for failure logging | `string` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Topic ARN |
| arn | Topic ARN |
| name | Topic name |
| owner | Topic owner account ID |

## Considerations

- FIFO topic names must end with `.fifo` (added automatically)
- FIFO topics can only have FIFO SQS queues as subscribers
- Display name is only used for SMS subscriptions (max 10 chars)
- KMS encryption requires subscribers to have decrypt permissions
- Delivery status logging creates CloudWatch log groups automatically
- Data protection policies can audit or block sensitive data patterns
