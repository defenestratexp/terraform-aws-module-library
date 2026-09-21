# ------------------------------------------------------------------------------
# ROUTE53 RECORDS MODULE
# Creates Route53 DNS records with various routing policies
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DNS RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "main" {
  for_each = var.records

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type

  # Standard records (non-alias)
  ttl     = each.value.alias == null ? each.value.ttl : null
  records = each.value.alias == null ? each.value.records : null

  # Alias records
  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  # Routing policy settings
  set_identifier  = each.value.routing_policy != "simple" ? each.value.set_identifier : null
  health_check_id = each.value.health_check_id

  # Weighted routing
  dynamic "weighted_routing_policy" {
    for_each = each.value.routing_policy == "weighted" ? [1] : []
    content {
      weight = each.value.weight
    }
  }

  # Latency routing
  dynamic "latency_routing_policy" {
    for_each = each.value.routing_policy == "latency" ? [1] : []
    content {
      region = each.value.latency_region
    }
  }

  # Geolocation routing
  dynamic "geolocation_routing_policy" {
    for_each = each.value.routing_policy == "geolocation" && each.value.geolocation != null ? [each.value.geolocation] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  # Failover routing
  dynamic "failover_routing_policy" {
    for_each = each.value.routing_policy == "failover" ? [1] : []
    content {
      type = each.value.failover_type
    }
  }

  # Multivalue answer
  multivalue_answer_routing_policy = each.value.routing_policy == "multivalue" ? each.value.multivalue_answer : null

  lifecycle {
    create_before_destroy = true
  }
}
