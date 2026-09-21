# Auto Scaling Group Module

Creates an Auto Scaling Group with optional scaling policies and instance refresh.

## Features

- Launch template integration
- Target group attachment for load balancers
- Instance refresh for rolling updates
- Target tracking scaling policy (CPU-based)
- Configurable health checks and lifecycle
- Tag propagation to instances
- Consistent naming and tagging

## Usage

### Basic Usage

```hcl
module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids

  min_size = 2
  max_size = 6
}
```

### With Load Balancer

```hcl
module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids

  min_size         = 2
  max_size         = 10
  desired_capacity = 4

  target_group_arns = [module.target_group.arn]
  health_check_type = "ELB"

  tags = {
    Environment = "production"
  }
}
```

### With Auto Scaling

```hcl
module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids

  min_size = 2
  max_size = 20

  enable_target_tracking_scaling = true
  target_tracking_cpu_target     = 70
}
```

### With Instance Refresh

```hcl
module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids

  min_size = 2
  max_size = 6

  instance_refresh_enabled                 = true
  instance_refresh_min_healthy_percentage  = 75
  instance_refresh_instance_warmup         = 300
}
```

### Complete Example

```hcl
module "launch_template" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/launch-template?ref=v1.0.0"

  name               = "acme-prod-web"
  instance_type      = "t3.small"
  security_group_ids = [module.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
  EOF
}

module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-web"
  vpc_id   = module.vpc.vpc_id
  port     = 80
  protocol = "HTTP"
}

module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids

  min_size         = 2
  max_size         = 10
  desired_capacity = 4

  target_group_arns         = [module.target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  enable_target_tracking_scaling = true
  target_tracking_cpu_target     = 70

  instance_refresh_enabled                = true
  instance_refresh_min_healthy_percentage = 75
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ASG | `string` | n/a | yes |
| launch_template_id | Launch template ID | `string` | n/a | yes |
| subnet_ids | Subnet IDs for instances | `list(string)` | n/a | yes |
| min_size | Minimum instances | `number` | `1` | no |
| max_size | Maximum instances | `number` | `3` | no |
| desired_capacity | Desired instances | `number` | `null` | no |
| launch_template_version | Template version | `string` | `"$Latest"` | no |
| health_check_type | Health check type (EC2, ELB) | `string` | `"EC2"` | no |
| health_check_grace_period | Grace period in seconds | `number` | `300` | no |
| default_cooldown | Cooldown in seconds | `number` | `300` | no |
| wait_for_capacity_timeout | Capacity wait timeout | `string` | `"10m"` | no |
| protect_from_scale_in | Protect from scale in | `bool` | `false` | no |
| termination_policies | Termination policies | `list(string)` | `["Default"]` | no |
| suspended_processes | Suspended processes | `list(string)` | `[]` | no |
| target_group_arns | Target group ARNs | `list(string)` | `[]` | no |
| instance_refresh_enabled | Enable instance refresh | `bool` | `false` | no |
| instance_refresh_strategy | Refresh strategy | `string` | `"Rolling"` | no |
| instance_refresh_min_healthy_percentage | Min healthy percentage | `number` | `50` | no |
| instance_refresh_instance_warmup | Instance warmup seconds | `number` | `null` | no |
| enable_target_tracking_scaling | Enable CPU scaling | `bool` | `false` | no |
| target_tracking_cpu_target | Target CPU percentage | `number` | `50` | no |
| target_tracking_disable_scale_in | Disable scale in | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |
| propagate_tags_at_launch | Tags to propagate | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the ASG |
| arn | The ARN of the ASG |
| name | The name of the ASG |
| min_size | Minimum size |
| max_size | Maximum size |
| desired_capacity | Desired capacity |
| availability_zones | Availability zones |
| vpc_zone_identifier | Subnet IDs |
| target_group_arns | Attached target groups |
| scaling_policy_arn | CPU scaling policy ARN |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- `desired_capacity` is ignored in lifecycle to prevent drift from manual scaling or scaling policies.
- Use `health_check_type = "ELB"` when attaching to a load balancer.
- Instance refresh triggers rolling replacement when launch template changes.
- Target tracking scaling automatically adjusts capacity based on CPU utilization.
