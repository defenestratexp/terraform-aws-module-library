# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DASHBOARD BODY
# ------------------------------------------------------------------------------

variable "dashboard_body" {
  description = "JSON string for the dashboard body (use jsonencode or file function)"
  type        = string
  default     = null
}

variable "widgets" {
  description = "List of widget configurations (alternative to dashboard_body)"
  type = list(object({
    type       = string
    x          = number
    y          = number
    width      = number
    height     = number
    properties = any
  }))
  default = []
}
