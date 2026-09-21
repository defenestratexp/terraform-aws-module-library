# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "topic_arn" {
  description = "ARN of the SNS topic to subscribe to"
  type        = string
}

variable "protocol" {
  description = "Protocol for the subscription (email, email-json, sms, sqs, lambda, http, https, application, firehose)"
  type        = string

  validation {
    condition     = contains(["email", "email-json", "sms", "sqs", "lambda", "http", "https", "application", "firehose"], var.protocol)
    error_message = "Protocol must be one of: email, email-json, sms, sqs, lambda, http, https, application, firehose."
  }
}

variable "endpoint" {
  description = "Endpoint for the subscription (email address, phone number, SQS ARN, Lambda ARN, HTTP(S) URL, etc.)"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DELIVERY OPTIONS
# ------------------------------------------------------------------------------

variable "raw_message_delivery" {
  description = "Enable raw message delivery (SQS, HTTP/S, Firehose only)"
  type        = bool
  default     = false
}

variable "confirmation_timeout_in_minutes" {
  description = "Confirmation timeout for HTTP/HTTPS endpoints (1-10080 minutes)"
  type        = number
  default     = null
}

variable "delivery_policy" {
  description = "Delivery policy JSON for HTTP/HTTPS endpoints"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FILTERING
# ------------------------------------------------------------------------------

variable "filter_policy" {
  description = "Filter policy JSON for message filtering"
  type        = string
  default     = null
}

variable "filter_policy_scope" {
  description = "Filter policy scope (MessageAttributes or MessageBody)"
  type        = string
  default     = null

  validation {
    condition     = var.filter_policy_scope == null || contains(["MessageAttributes", "MessageBody"], var.filter_policy_scope)
    error_message = "Filter policy scope must be MessageAttributes or MessageBody."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DEAD LETTER QUEUE
# ------------------------------------------------------------------------------

variable "redrive_policy" {
  description = "Redrive policy JSON for dead letter queue"
  type        = string
  default     = null
}

variable "dead_letter_queue_arn" {
  description = "ARN of the SQS queue for failed deliveries (alternative to redrive_policy)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SUBSCRIPTION ARN
# ------------------------------------------------------------------------------

variable "subscription_role_arn" {
  description = "IAM role ARN for Firehose subscriptions"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LAMBDA PERMISSIONS
# ------------------------------------------------------------------------------

variable "create_lambda_permission" {
  description = "Create Lambda permission for SNS to invoke the function"
  type        = bool
  default     = true
}
