# ------------------------------------------------------------------------------
# SNS SUBSCRIPTION MODULE
# Creates an SNS subscription with optional filtering and DLQ
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  # Build redrive policy from DLQ ARN if provided
  redrive_policy = var.redrive_policy != null ? var.redrive_policy : (
    var.dead_letter_queue_arn != null ? jsonencode({
      deadLetterTargetArn = var.dead_letter_queue_arn
    }) : null
  )

  # Identify if this is a Lambda subscription
  is_lambda = var.protocol == "lambda"

  # Extract function name from ARN for Lambda permission
  lambda_function_name = local.is_lambda ? regex("function:([^:]+)", var.endpoint)[0] : null
}

# ------------------------------------------------------------------------------
# SNS SUBSCRIPTION
# ------------------------------------------------------------------------------

resource "aws_sns_topic_subscription" "main" {
  topic_arn = var.topic_arn
  protocol  = var.protocol
  endpoint  = var.endpoint

  # Delivery options
  raw_message_delivery            = var.raw_message_delivery
  confirmation_timeout_in_minutes = var.confirmation_timeout_in_minutes
  delivery_policy                 = var.delivery_policy

  # Filtering
  filter_policy       = var.filter_policy
  filter_policy_scope = var.filter_policy_scope

  # Dead letter queue
  redrive_policy = local.redrive_policy

  # Firehose role
  subscription_role_arn = var.subscription_role_arn

  # Prevent Terraform from attempting to confirm email/SMS subscriptions
  endpoint_auto_confirms = contains(["email", "email-json", "sms"], var.protocol) ? false : true
}

# ------------------------------------------------------------------------------
# LAMBDA PERMISSION
# ------------------------------------------------------------------------------

resource "aws_lambda_permission" "sns" {
  count = local.is_lambda && var.create_lambda_permission ? 1 : 0

  statement_id  = "AllowSNSInvoke-${md5(var.topic_arn)}"
  action        = "lambda:InvokeFunction"
  function_name = var.endpoint
  principal     = "sns.amazonaws.com"
  source_arn    = var.topic_arn
}
