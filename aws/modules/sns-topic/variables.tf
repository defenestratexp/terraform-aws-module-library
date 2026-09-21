# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the SNS topic (for FIFO topics, .fifo suffix is added automatically)"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TOPIC TYPE
# ------------------------------------------------------------------------------

variable "fifo_topic" {
  description = "Whether this is a FIFO topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DISPLAY AND DELIVERY
# ------------------------------------------------------------------------------

variable "display_name" {
  description = "Display name for SMS messages"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "SNS delivery policy JSON"
  type        = string
  default     = null
}

variable "application_success_feedback_role_arn" {
  description = "IAM role for application delivery success feedback"
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "Sample rate for application delivery success feedback (0-100)"
  type        = number
  default     = null
}

variable "application_failure_feedback_role_arn" {
  description = "IAM role for application delivery failure feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_role_arn" {
  description = "IAM role for HTTP delivery success feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "Sample rate for HTTP delivery success feedback (0-100)"
  type        = number
  default     = null
}

variable "http_failure_feedback_role_arn" {
  description = "IAM role for HTTP delivery failure feedback"
  type        = string
  default     = null
}

variable "lambda_success_feedback_role_arn" {
  description = "IAM role for Lambda delivery success feedback"
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "Sample rate for Lambda delivery success feedback (0-100)"
  type        = number
  default     = null
}

variable "lambda_failure_feedback_role_arn" {
  description = "IAM role for Lambda delivery failure feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "IAM role for SQS delivery success feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "Sample rate for SQS delivery success feedback (0-100)"
  type        = number
  default     = null
}

variable "sqs_failure_feedback_role_arn" {
  description = "IAM role for SQS delivery failure feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "IAM role for Firehose delivery success feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "Sample rate for Firehose delivery success feedback (0-100)"
  type        = number
  default     = null
}

variable "firehose_failure_feedback_role_arn" {
  description = "IAM role for Firehose delivery failure feedback"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "kms_master_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS POLICY
# ------------------------------------------------------------------------------

variable "policy" {
  description = "Topic policy JSON document"
  type        = string
  default     = null
}

variable "create_publish_policy" {
  description = "Create policy allowing specific principals to publish"
  type        = bool
  default     = false
}

variable "publish_principal_arns" {
  description = "IAM principal ARNs allowed to publish (requires create_publish_policy)"
  type        = list(string)
  default     = []
}

variable "create_eventbridge_policy" {
  description = "Create policy allowing EventBridge to publish"
  type        = bool
  default     = false
}

variable "eventbridge_rule_arns" {
  description = "EventBridge rule ARNs allowed to publish (requires create_eventbridge_policy)"
  type        = list(string)
  default     = []
}

variable "create_s3_policy" {
  description = "Create policy allowing S3 event notifications"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs allowed to publish (requires create_s3_policy)"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DATA PROTECTION
# ------------------------------------------------------------------------------

variable "data_protection_policy" {
  description = "Data protection policy JSON for sensitive data"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ARCHIVE POLICY
# ------------------------------------------------------------------------------

variable "archive_policy" {
  description = "Message archive policy JSON (for FIFO topics)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
