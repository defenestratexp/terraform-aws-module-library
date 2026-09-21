# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "alarm_name" {
  description = "Name of the CloudWatch alarm"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ALARM TYPE
# ------------------------------------------------------------------------------

variable "alarm_type" {
  description = "Type of alarm: metric or composite"
  type        = string
  default     = "metric"

  validation {
    condition     = contains(["metric", "composite"], var.alarm_type)
    error_message = "Alarm type must be metric or composite."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - METRIC ALARM SETTINGS
# ------------------------------------------------------------------------------

variable "metric_name" {
  description = "Name of the metric (for metric alarms)"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Namespace of the metric (for metric alarms)"
  type        = string
  default     = null
}

variable "comparison_operator" {
  description = "Comparison operator for the alarm"
  type        = string
  default     = "GreaterThanThreshold"

  validation {
    condition = contains([
      "GreaterThanOrEqualToThreshold",
      "GreaterThanThreshold",
      "LessThanThreshold",
      "LessThanOrEqualToThreshold",
      "LessThanLowerOrGreaterThanUpperThreshold",
      "LessThanLowerThreshold",
      "GreaterThanUpperThreshold"
    ], var.comparison_operator)
    error_message = "Invalid comparison operator."
  }
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate"
  type        = number
  default     = 1
}

variable "period" {
  description = "Period in seconds for metric evaluation"
  type        = number
  default     = 300
}

variable "statistic" {
  description = "Statistic for the metric (Average, Sum, Minimum, Maximum, SampleCount)"
  type        = string
  default     = null
}

variable "extended_statistic" {
  description = "Extended statistic (e.g., p99, p95)"
  type        = string
  default     = null
}

variable "threshold" {
  description = "Threshold for the alarm"
  type        = number
  default     = null
}

variable "threshold_metric_id" {
  description = "Metric ID for anomaly detection threshold"
  type        = string
  default     = null
}

variable "dimensions" {
  description = "Dimensions for the metric"
  type        = map(string)
  default     = {}
}

variable "unit" {
  description = "Unit for the metric"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - METRIC QUERY (FOR MATH EXPRESSIONS)
# ------------------------------------------------------------------------------

variable "metric_queries" {
  description = "Metric queries for math expressions or multiple metrics"
  type = list(object({
    id          = string
    expression  = optional(string)
    label       = optional(string)
    return_data = optional(bool, true)
    period      = optional(number)
    metric = optional(object({
      metric_name = string
      namespace   = string
      period      = number
      stat        = string
      dimensions  = optional(map(string), {})
      unit        = optional(string)
    }))
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - COMPOSITE ALARM SETTINGS
# ------------------------------------------------------------------------------

variable "alarm_rule" {
  description = "Alarm rule for composite alarms (e.g., ALARM(alarm1) OR ALARM(alarm2))"
  type        = string
  default     = null
}

variable "actions_suppressor" {
  description = "Actions suppressor alarm name"
  type        = string
  default     = null
}

variable "actions_suppressor_wait_period" {
  description = "Wait period for actions suppressor (seconds)"
  type        = number
  default     = null
}

variable "actions_suppressor_extension_period" {
  description = "Extension period for actions suppressor (seconds)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ALARM BEHAVIOR
# ------------------------------------------------------------------------------

variable "alarm_description" {
  description = "Description of the alarm"
  type        = string
  default     = ""
}

variable "datapoints_to_alarm" {
  description = "Number of datapoints that must breach threshold (M of N)"
  type        = number
  default     = null
}

variable "treat_missing_data" {
  description = "How to treat missing data (missing, ignore, breaching, notBreaching)"
  type        = string
  default     = "missing"

  validation {
    condition     = contains(["missing", "ignore", "breaching", "notBreaching"], var.treat_missing_data)
    error_message = "treat_missing_data must be missing, ignore, breaching, or notBreaching."
  }
}

variable "evaluate_low_sample_count_percentiles" {
  description = "Evaluate low sample count percentiles (evaluate or ignore)"
  type        = string
  default     = null
}

variable "actions_enabled" {
  description = "Enable alarm actions"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ALARM ACTIONS
# ------------------------------------------------------------------------------

variable "alarm_actions" {
  description = "Actions to execute when alarm transitions to ALARM state"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "Actions to execute when alarm transitions to OK state"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "Actions to execute when alarm transitions to INSUFFICIENT_DATA state"
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
