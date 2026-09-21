# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "layer_name" {
  description = "Name of the Lambda layer"
  type        = string
}

variable "compatible_runtimes" {
  description = "List of compatible runtimes"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SOURCE
# ------------------------------------------------------------------------------

variable "source_path" {
  description = "Path to source directory (creates zip automatically)"
  type        = string
  default     = null
}

variable "filename" {
  description = "Path to the layer zip file"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the layer package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the layer package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the layer package"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LAYER CONFIGURATION
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the layer"
  type        = string
  default     = ""
}

variable "compatible_architectures" {
  description = "List of compatible architectures (x86_64, arm64)"
  type        = list(string)
  default     = ["x86_64"]
}

variable "license_info" {
  description = "License information for the layer"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PERMISSIONS
# ------------------------------------------------------------------------------

variable "permission_statements" {
  description = "Map of permission statements for layer access"
  type = map(object({
    principal       = string
    organization_id = optional(string)
  }))
  default = {}
}

variable "skip_destroy" {
  description = "Keep old layer versions when creating new versions"
  type        = bool
  default     = false
}
