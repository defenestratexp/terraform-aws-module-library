# ------------------------------------------------------------------------------
# SNS TOPIC MODULE
# Creates an SNS topic with access policies
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "sns-topic"
  }

  tags = merge(local.default_tags, var.tags)

  # FIFO topics must have .fifo suffix
  topic_name = var.fifo_topic ? (
    endswith(var.name, ".fifo") ? var.name : "${var.name}.fifo"
  ) : var.name
}

# ------------------------------------------------------------------------------
# SNS TOPIC
# ------------------------------------------------------------------------------

resource "aws_sns_topic" "main" {
  name         = local.topic_name
  display_name = var.display_name

  # FIFO settings
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null

  # Encryption
  kms_master_key_id = var.kms_master_key_id

  # Delivery policy
  delivery_policy = var.delivery_policy

  # Application delivery feedback
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn

  # HTTP delivery feedback
  http_success_feedback_role_arn    = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn    = var.http_failure_feedback_role_arn

  # Lambda delivery feedback
  lambda_success_feedback_role_arn    = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn    = var.lambda_failure_feedback_role_arn

  # SQS delivery feedback
  sqs_success_feedback_role_arn    = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn    = var.sqs_failure_feedback_role_arn

  # Firehose delivery feedback
  firehose_success_feedback_role_arn    = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn    = var.firehose_failure_feedback_role_arn

  # Archive policy (FIFO only)
  archive_policy = var.fifo_topic ? var.archive_policy : null

  tags = merge(local.tags, {
    Name = local.topic_name
  })
}

# ------------------------------------------------------------------------------
# DATA PROTECTION POLICY
# ------------------------------------------------------------------------------

resource "aws_sns_topic_data_protection_policy" "main" {
  count = var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.main.arn
  policy = var.data_protection_policy
}

# ------------------------------------------------------------------------------
# TOPIC POLICY
# ------------------------------------------------------------------------------

# Custom policy
resource "aws_sns_topic_policy" "custom" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.main.arn
  policy = var.policy
}

# Generated policy for common use cases
data "aws_iam_policy_document" "generated" {
  count = var.policy == null && (var.create_publish_policy || var.create_eventbridge_policy || var.create_s3_policy) ? 1 : 0

  # Allow account owner full access
  statement {
    sid    = "AllowAccountOwner"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
    ]

    resources = [aws_sns_topic.main.arn]
  }

  # Allow specific principals to publish
  dynamic "statement" {
    for_each = var.create_publish_policy && length(var.publish_principal_arns) > 0 ? [1] : []
    content {
      sid    = "AllowPublish"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.publish_principal_arns
      }

      actions   = ["sns:Publish"]
      resources = [aws_sns_topic.main.arn]
    }
  }

  # Allow EventBridge to publish
  dynamic "statement" {
    for_each = var.create_eventbridge_policy ? [1] : []
    content {
      sid    = "AllowEventBridgePublish"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["events.amazonaws.com"]
      }

      actions   = ["sns:Publish"]
      resources = [aws_sns_topic.main.arn]

      dynamic "condition" {
        for_each = length(var.eventbridge_rule_arns) > 0 ? [1] : []
        content {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = var.eventbridge_rule_arns
        }
      }
    }
  }

  # Allow S3 event notifications
  dynamic "statement" {
    for_each = var.create_s3_policy ? [1] : []
    content {
      sid    = "AllowS3Publish"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["s3.amazonaws.com"]
      }

      actions   = ["sns:Publish"]
      resources = [aws_sns_topic.main.arn]

      dynamic "condition" {
        for_each = length(var.s3_bucket_arns) > 0 ? [1] : []
        content {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = var.s3_bucket_arns
        }
      }
    }
  }
}

resource "aws_sns_topic_policy" "generated" {
  count = var.policy == null && (var.create_publish_policy || var.create_eventbridge_policy || var.create_s3_policy) ? 1 : 0

  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.generated[0].json
}
