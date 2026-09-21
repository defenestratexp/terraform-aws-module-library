# Naming Conventions and Standards

Consistent standards for all modules in this module library.

## Module Naming

### Directory Structure
```
aws/modules/{resource-type}/
```

Use lowercase, hyphen-separated names matching the AWS resource:
- `vpc` (not `virtual-private-cloud`)
- `nat-gateway` (not `nat` or `natgw`)
- `security-group` (not `sg`)
- `s3-bucket` (not `s3` or `bucket`)
- `rds-instance` (not `rds` or `database`)

### File Structure

Every module contains:
```
aws/modules/{module-name}/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variables with descriptions
├── outputs.tf        # Output values
├── versions.tf       # Provider and Terraform version constraints
├── README.md         # Usage documentation
└── locals.tf         # (optional) Local values and computed values
```

---

## Variable Conventions

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `name` | `string` | Base name for all resources in the module |
| `tags` | `map(string)` | Additional tags to merge with defaults |

### Optional Common Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | `string` | `""` | Environment name (dev, staging, prod) |
| `create` | `bool` | `true` | Whether to create the resource |

### Variable Naming Rules

1. **Use full words** - `subnet_ids` not `sub_ids`
2. **Use snake_case** - `availability_zones` not `availabilityZones`
3. **Boolean prefixes** - `enable_*`, `create_*`, `use_*`
4. **ID suffixes** - `vpc_id`, `subnet_ids`, `security_group_ids`
5. **ARN suffixes** - `kms_key_arn`, `role_arn`

### Variable Definitions

Always include:
```hcl
variable "example" {
  description = "Clear description of what this variable does"
  type        = string
  default     = "sensible-default"  # if applicable

  validation {  # if applicable
    condition     = length(var.example) > 0
    error_message = "Example cannot be empty."
  }
}
```

Mark sensitive variables:
```hcl
variable "password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

---

## Output Conventions

### Required Outputs

Every module should output at minimum:
```hcl
output "id" {
  description = "The ID of the primary resource"
  value       = aws_resource.main.id
}
```

### Common Outputs

| Output | Description |
|--------|-------------|
| `id` | Primary resource ID |
| `arn` | Resource ARN |
| `name` | Resource name |
| `*_ids` | List of IDs (e.g., `subnet_ids`) |
| `*_arns` | List of ARNs |

### Output Naming Rules

1. **Match the resource attribute** - If AWS calls it `id`, output `id`
2. **Pluralize lists** - `subnet_ids` not `subnet_id` for lists
3. **Group related outputs** - Use maps for complex resources

Example:
```hcl
output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.main[*].id
}

output "subnets" {
  description = "Map of subnet details"
  value = {
    for k, v in aws_subnet.main : k => {
      id         = v.id
      arn        = v.arn
      cidr_block = v.cidr_block
    }
  }
}
```

---

## Resource Naming

### Name Tag Pattern
```
{name}[-{descriptor}][-{index}]
```

Examples:
| Resource | Name Variable | Result |
|----------|---------------|--------|
| VPC | `acme-prod` | `acme-prod` |
| Public Subnet AZ-a | `acme-prod` | `acme-prod-public-1` |
| Private Subnet AZ-b | `acme-prod` | `acme-prod-private-2` |
| NAT Gateway | `acme-prod` | `acme-prod-nat-1` |
| Security Group | `acme-prod` | `acme-prod-web` |
| ALB | `acme-prod` | `acme-prod-alb` |

### Implementation
```hcl
locals {
  name_prefix = var.name
}

resource "aws_vpc" "main" {
  # ...
  tags = merge(var.tags, {
    Name = local.name_prefix
  })
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  # ...
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
  })
}
```

---

## Tagging Standards

### Default Tags

Every module applies these tags automatically:
```hcl
locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "{module-name}"
  }
}
```

### Merged Tags

Always merge user tags with defaults:
```hcl
tags = merge(
  local.default_tags,
  var.tags,
  {
    Name = "{resource-name}"
  }
)
```

### Recommended Client Tags

Clients should pass these via the `tags` variable:
```hcl
tags = {
  Client      = "ACME Corp"
  Environment = "production"
  Project     = "web-platform"
  CostCenter  = "engineering"
}
```

---

## Version Constraints

### versions.tf Template
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
```

### Rules
- Terraform: `>= 1.5.0` (recent stable)
- AWS Provider: `>= 5.0.0` (current major version)
- Use `>=` not `~>` for flexibility

---

## Documentation Standards

### README.md Template

Every module README includes:
1. **Title and description**
2. **Features list**
3. **Usage examples** (basic and advanced)
4. **Inputs table** (all variables)
5. **Outputs table** (all outputs)
6. **Requirements table** (versions)

### Example Inputs Table
```markdown
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for resources | `string` | n/a | yes |
| tags | Additional tags | `map(string)` | `{}` | no |
```

### Example Outputs Table
```markdown
| Name | Description |
|------|-------------|
| id | The VPC ID |
| arn | The VPC ARN |
```

---

## Code Style

### Formatting
- Run `terraform fmt` before committing
- Use 2-space indentation (Terraform default)

### Ordering in Files

**variables.tf:**
1. Required variables (no default)
2. Optional variables (with default)
3. Alphabetical within each group

**outputs.tf:**
1. Primary outputs (id, arn, name)
2. Secondary outputs
3. Convenience/computed outputs

**main.tf:**
1. `locals` block
2. `data` sources
3. `resource` blocks (in logical order)

### Comments
```hcl
# Use comments sparingly - code should be self-documenting
# Comments explain WHY, not WHAT

# Required for ECS service discovery
resource "aws_service_discovery_private_dns_namespace" "main" {
  # ...
}
```
