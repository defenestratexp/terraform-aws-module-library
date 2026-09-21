# ------------------------------------------------------------------------------
# SECURITY GROUP MODULE
# Creates a security group with configurable ingress and egress rules
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  # Standard tags
  default_tags = {
    ManagedBy = "terraform"
    Module    = "security-group"
  }

  tags = merge(local.default_tags, var.tags)

  # Default egress rule (allow all outbound)
  default_egress = var.allow_all_egress ? [
    {
      from_port                     = 0
      to_port                       = 0
      protocol                      = "-1"
      cidr_blocks                   = ["0.0.0.0/0"]
      ipv6_cidr_blocks              = []
      destination_security_group_id = null
      self                          = false
      description                   = "Allow all outbound traffic"
    }
  ] : []

  # Combine user-provided egress rules with default
  all_egress_rules = concat(local.default_egress, var.egress_rules)
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "main" {
  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = merge(local.tags, {
    Name = var.name
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# INGRESS RULES
# ------------------------------------------------------------------------------

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = "ingress"
  security_group_id = aws_security_group.main.id

  from_port   = var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].to_port
  protocol    = var.ingress_rules[count.index].protocol
  description = var.ingress_rules[count.index].description

  # Only one of these can be set
  cidr_blocks              = length(var.ingress_rules[count.index].cidr_blocks) > 0 ? var.ingress_rules[count.index].cidr_blocks : null
  ipv6_cidr_blocks         = length(var.ingress_rules[count.index].ipv6_cidr_blocks) > 0 ? var.ingress_rules[count.index].ipv6_cidr_blocks : null
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id
  self                     = var.ingress_rules[count.index].self ? true : null
}

# ------------------------------------------------------------------------------
# EGRESS RULES
# ------------------------------------------------------------------------------

resource "aws_security_group_rule" "egress" {
  count = length(local.all_egress_rules)

  type              = "egress"
  security_group_id = aws_security_group.main.id

  from_port   = local.all_egress_rules[count.index].from_port
  to_port     = local.all_egress_rules[count.index].to_port
  protocol    = local.all_egress_rules[count.index].protocol
  description = local.all_egress_rules[count.index].description

  # Only one of these can be set
  cidr_blocks              = length(local.all_egress_rules[count.index].cidr_blocks) > 0 ? local.all_egress_rules[count.index].cidr_blocks : null
  ipv6_cidr_blocks         = length(local.all_egress_rules[count.index].ipv6_cidr_blocks) > 0 ? local.all_egress_rules[count.index].ipv6_cidr_blocks : null
  source_security_group_id = local.all_egress_rules[count.index].destination_security_group_id
  self                     = local.all_egress_rules[count.index].self ? true : null
}
