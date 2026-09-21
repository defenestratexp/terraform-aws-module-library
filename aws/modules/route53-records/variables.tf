# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RECORDS
# ------------------------------------------------------------------------------

variable "records" {
  description = "Map of DNS records to create"
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), [])

    # Alias record settings
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    }), null)

    # Health check settings
    health_check_id = optional(string, null)
    set_identifier  = optional(string, null)

    # Routing policies
    routing_policy = optional(string, "simple") # simple, weighted, latency, geolocation, failover, multivalue

    # Weighted routing
    weight = optional(number, null)

    # Latency routing
    latency_region = optional(string, null)

    # Geolocation routing
    geolocation = optional(object({
      continent   = optional(string, null)
      country     = optional(string, null)
      subdivision = optional(string, null)
    }), null)

    # Failover routing
    failover_type = optional(string, null) # PRIMARY or SECONDARY

    # Multivalue answer
    multivalue_answer = optional(bool, null)
  }))
  default = {}
}
