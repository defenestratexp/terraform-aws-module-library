# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name for the flow log and related resources"
  type        = string
}

variable "resource_id" {
  description = "ID of the VPC, subnet, or network interface to monitor"
  type        = string
}

variable "resource_type" {
  description = "Type of resource to monitor (VPC, Subnet, NetworkInterface)"
  type        = string

  validation {
    condition     = contains(["VPC", "Subnet", "NetworkInterface"], var.resource_type)
    error_message = "Resource type must be VPC, Subnet, or NetworkInterface."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DESTINATION
# ------------------------------------------------------------------------------

variable "destination_type" {
  description = "Destination type (cloud-watch-logs, s3, kinesis-data-firehose)"
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition     = contains(["cloud-watch-logs", "s3", "kinesis-data-firehose"], var.destination_type)
    error_message = "Destination type must be cloud-watch-logs, s3, or kinesis-data-firehose."
  }
}

variable "log_group_name" {
  description = "CloudWatch log group name (for cloud-watch-logs destination)"
  type        = string
  default     = null
}

variable "create_log_group" {
  description = "Create CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_group_retention_in_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "log_group_kms_key_id" {
  description = "KMS key ARN for CloudWatch log group encryption"
  type        = string
  default     = null
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN (for s3 destination)"
  type        = string
  default     = null
}

variable "s3_key_prefix" {
  description = "S3 key prefix for flow log files"
  type        = string
  default     = null
}

variable "firehose_arn" {
  description = "Kinesis Firehose delivery stream ARN (for kinesis-data-firehose destination)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FLOW LOG SETTINGS
# ------------------------------------------------------------------------------

variable "traffic_type" {
  description = "Type of traffic to capture (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "Traffic type must be ACCEPT, REJECT, or ALL."
  }
}

variable "max_aggregation_interval" {
  description = "Maximum aggregation interval in seconds (60 or 600)"
  type        = number
  default     = 600

  validation {
    condition     = contains([60, 600], var.max_aggregation_interval)
    error_message = "Max aggregation interval must be 60 or 600 seconds."
  }
}

variable "log_format" {
  description = "Custom log format (null for default format)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM ROLE
# ------------------------------------------------------------------------------

variable "create_iam_role" {
  description = "Create IAM role for CloudWatch Logs destination"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN (for cloud-watch-logs destination)"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary ARN for the IAM role"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DESTINATION OPTIONS
# ------------------------------------------------------------------------------

variable "file_format" {
  description = "File format for S3 destination (plain-text or parquet)"
  type        = string
  default     = "plain-text"

  validation {
    condition     = contains(["plain-text", "parquet"], var.file_format)
    error_message = "File format must be plain-text or parquet."
  }
}

variable "hive_compatible_partitions" {
  description = "Use Hive-compatible S3 prefixes"
  type        = bool
  default     = false
}

variable "per_hour_partition" {
  description = "Partition flow logs per hour"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
