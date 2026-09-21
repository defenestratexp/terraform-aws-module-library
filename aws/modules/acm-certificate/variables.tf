# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.domain_name)) || can(regex("^\\*\\.[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.domain_name))
    error_message = "Domain name must be a valid domain or wildcard domain."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DOMAINS
# ------------------------------------------------------------------------------

variable "subject_alternative_names" {
  description = "List of additional domain names (SANs)"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VALIDATION
# ------------------------------------------------------------------------------

variable "validation_method" {
  description = "Validation method (DNS or EMAIL)"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "Validation method must be DNS or EMAIL."
  }
}

variable "create_route53_records" {
  description = "Create Route53 validation records (DNS validation only)"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 zone ID for DNS validation records"
  type        = string
  default     = ""
}

variable "wait_for_validation" {
  description = "Wait for certificate validation to complete"
  type        = bool
  default     = true
}

variable "validation_timeout" {
  description = "Timeout for validation (e.g., 45m)"
  type        = string
  default     = "45m"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - KEY ALGORITHM
# ------------------------------------------------------------------------------

variable "key_algorithm" {
  description = "Key algorithm (RSA_2048, EC_prime256v1, EC_secp384r1, EC_secp521r1)"
  type        = string
  default     = "RSA_2048"

  validation {
    condition     = contains(["RSA_2048", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], var.key_algorithm)
    error_message = "Key algorithm must be RSA_2048, EC_prime256v1, EC_secp384r1, or EC_secp521r1."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - OPTIONS
# ------------------------------------------------------------------------------

variable "certificate_transparency_logging_preference" {
  description = "Certificate transparency logging preference (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.certificate_transparency_logging_preference)
    error_message = "Certificate transparency logging preference must be ENABLED or DISABLED."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
