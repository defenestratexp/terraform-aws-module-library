# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the SQS queue (for FIFO queues, .fifo suffix is added automatically)"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - QUEUE TYPE
# ------------------------------------------------------------------------------

variable "fifo_queue" {
  description = "Whether this is a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "Deduplication scope for FIFO queues (messageGroup or queue)"
  type        = string
  default     = null
}

variable "fifo_throughput_limit" {
  description = "FIFO throughput limit (perQueue or perMessageGroupId)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MESSAGE SETTINGS
# ------------------------------------------------------------------------------

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for messages (0-43200 seconds)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Message retention period (60-1209600 seconds, default 4 days)"
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "Maximum message size in bytes (1024-262144)"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Delay for all messages (0-900 seconds)"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time (0-20 seconds)"
  type        = number
  default     = 0
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "sqs_managed_sse_enabled" {
  description = "Enable SQS-managed server-side encryption"
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption (overrides SQS-managed SSE)"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "KMS data key reuse period (60-86400 seconds)"
  type        = number
  default     = 300
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DEAD LETTER QUEUE
# ------------------------------------------------------------------------------

variable "dead_letter_queue_arn" {
  description = "ARN of the dead letter queue"
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Max receives before sending to DLQ"
  type        = number
  default     = 5
}

variable "create_dlq" {
  description = "Create a dead letter queue for this queue"
  type        = bool
  default     = false
}

variable "dlq_message_retention_seconds" {
  description = "Message retention for the DLQ (default 14 days)"
  type        = number
  default     = 1209600
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REDRIVE ALLOW POLICY
# ------------------------------------------------------------------------------

variable "redrive_allow_policy" {
  description = "Redrive allow policy for this queue as DLQ"
  type = object({
    redrivePermission = string
    sourceQueueArns   = optional(list(string))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS POLICY
# ------------------------------------------------------------------------------

variable "policy" {
  description = "Queue policy JSON document"
  type        = string
  default     = null
}

variable "create_sns_policy" {
  description = "Create policy allowing SNS topics to send messages"
  type        = bool
  default     = false
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs allowed to send messages (requires create_sns_policy)"
  type        = list(string)
  default     = []
}

variable "create_lambda_policy" {
  description = "Create policy allowing Lambda to read messages"
  type        = bool
  default     = false
}

variable "lambda_function_arns" {
  description = "Lambda function ARNs allowed to read (requires create_lambda_policy)"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
