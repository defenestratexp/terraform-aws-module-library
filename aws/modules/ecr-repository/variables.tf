# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REPOSITORY SETTINGS
# ------------------------------------------------------------------------------

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "force_delete" {
  description = "Delete repository even if it contains images"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "encryption_type" {
  description = "Encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IMAGE SCANNING
# ------------------------------------------------------------------------------

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LIFECYCLE POLICY
# ------------------------------------------------------------------------------

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for image cleanup"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to keep (for lifecycle policy)"
  type        = number
  default     = 30
}

variable "untagged_image_expiry_days" {
  description = "Days after which untagged images expire"
  type        = number
  default     = 7
}

variable "custom_lifecycle_policy" {
  description = "Custom lifecycle policy JSON (overrides default if provided)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REPOSITORY POLICY
# ------------------------------------------------------------------------------

variable "repository_policy" {
  description = "Repository policy JSON for cross-account access"
  type        = string
  default     = null
}

variable "allow_pull_accounts" {
  description = "List of AWS account IDs allowed to pull images"
  type        = list(string)
  default     = []
}

variable "allow_push_accounts" {
  description = "List of AWS account IDs allowed to push images"
  type        = list(string)
  default     = []
}

variable "allow_lambda_pull" {
  description = "Allow AWS Lambda service to pull images"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REPLICATION
# ------------------------------------------------------------------------------

variable "replication_destinations" {
  description = "List of replication destinations"
  type = list(object({
    region      = string
    registry_id = optional(string)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
