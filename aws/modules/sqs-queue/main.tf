# ------------------------------------------------------------------------------
# SQS QUEUE MODULE
# Creates an SQS queue with optional dead letter queue
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
    Module    = "sqs-queue"
  }

  tags = merge(local.default_tags, var.tags)

  # FIFO queues must have .fifo suffix
  queue_name = var.fifo_queue ? (
    endswith(var.name, ".fifo") ? var.name : "${var.name}.fifo"
  ) : var.name

  dlq_name = var.fifo_queue ? "${var.name}-dlq.fifo" : "${var.name}-dlq"

  # Use KMS if specified, otherwise use SQS-managed SSE
  use_kms = var.kms_master_key_id != null
}

# ------------------------------------------------------------------------------
# DEAD LETTER QUEUE (OPTIONAL)
# ------------------------------------------------------------------------------

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name = local.dlq_name

  # FIFO settings must match main queue
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  # Message settings
  message_retention_seconds  = var.dlq_message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Encryption - match main queue
  sqs_managed_sse_enabled           = local.use_kms ? false : var.sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = local.use_kms ? var.kms_data_key_reuse_period_seconds : null

  tags = merge(local.tags, {
    Name = local.dlq_name
  })
}

# ------------------------------------------------------------------------------
# MAIN QUEUE
# ------------------------------------------------------------------------------

resource "aws_sqs_queue" "main" {
  name = local.queue_name

  # FIFO settings
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue ? var.fifo_throughput_limit : null

  # Message settings
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # Encryption
  sqs_managed_sse_enabled           = local.use_kms ? false : var.sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = local.use_kms ? var.kms_data_key_reuse_period_seconds : null

  # Dead letter queue
  redrive_policy = var.dead_letter_queue_arn != null || var.create_dlq ? jsonencode({
    deadLetterTargetArn = var.create_dlq ? aws_sqs_queue.dlq[0].arn : var.dead_letter_queue_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # Redrive allow policy (when this queue is used as a DLQ)
  redrive_allow_policy = var.redrive_allow_policy != null ? jsonencode(var.redrive_allow_policy) : null

  tags = merge(local.tags, {
    Name = local.queue_name
  })
}

# ------------------------------------------------------------------------------
# QUEUE POLICY
# ------------------------------------------------------------------------------

# Custom policy
resource "aws_sqs_queue_policy" "custom" {
  count = var.policy != null ? 1 : 0

  queue_url = aws_sqs_queue.main.id
  policy    = var.policy
}

# SNS subscription policy
data "aws_iam_policy_document" "sns" {
  count = var.create_sns_policy && length(var.sns_topic_arns) > 0 ? 1 : 0

  statement {
    sid    = "AllowSNSPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = var.sns_topic_arns
    }
  }
}

resource "aws_sqs_queue_policy" "sns" {
  count = var.create_sns_policy && length(var.sns_topic_arns) > 0 && var.policy == null ? 1 : 0

  queue_url = aws_sqs_queue.main.id
  policy    = data.aws_iam_policy_document.sns[0].json
}

# DLQ redrive allow policy
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.main.arn]
  })
}
