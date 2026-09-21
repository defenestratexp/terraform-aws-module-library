# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Athena workgroup"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - WORKGROUP SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the workgroup"
  type        = string
  default     = null
}

variable "state" {
  description = "State of the workgroup (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.state)
    error_message = "State must be ENABLED or DISABLED."
  }
}

variable "force_destroy" {
  description = "Force destroy workgroup and all queries"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RESULT CONFIGURATION
# ------------------------------------------------------------------------------

variable "output_location" {
  description = "S3 location for query results (e.g., s3://bucket/prefix/)"
  type        = string
  default     = null
}

variable "encryption_configuration" {
  description = "Encryption configuration for query results"
  type = object({
    encryption_option = string
    kms_key_arn       = optional(string)
  })
  default = null

  validation {
    condition = var.encryption_configuration == null || contains(
      ["SSE_S3", "SSE_KMS", "CSE_KMS"],
      var.encryption_configuration.encryption_option
    )
    error_message = "Encryption option must be SSE_S3, SSE_KMS, or CSE_KMS."
  }
}

variable "expected_bucket_owner" {
  description = "Expected owner of the S3 bucket"
  type        = string
  default     = null
}

variable "acl_configuration" {
  description = "ACL configuration for query results"
  type = object({
    s3_acl_option = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - QUERY LIMITS
# ------------------------------------------------------------------------------

variable "bytes_scanned_cutoff_per_query" {
  description = "Maximum bytes scanned per query (enforced limit)"
  type        = number
  default     = null
}

variable "execution_role" {
  description = "IAM role ARN for query execution"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENGINE
# ------------------------------------------------------------------------------

variable "engine_version" {
  description = "Athena engine version (e.g., Athena engine version 3)"
  type = object({
    selected_engine_version = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLOUDWATCH
# ------------------------------------------------------------------------------

variable "publish_cloudwatch_metrics_enabled" {
  description = "Publish query metrics to CloudWatch"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REQUESTER PAYS
# ------------------------------------------------------------------------------

variable "requester_pays_enabled" {
  description = "Allow queries on requester-pays S3 buckets"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENFORCE WORKGROUP CONFIG
# ------------------------------------------------------------------------------

variable "enforce_workgroup_configuration" {
  description = "Enforce workgroup configuration on client-side settings"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NAMED QUERIES
# ------------------------------------------------------------------------------

variable "named_queries" {
  description = "Map of named queries to create"
  type = map(object({
    description = optional(string)
    database    = string
    query       = string
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
