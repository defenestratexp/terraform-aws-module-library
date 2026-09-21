# Target Group Module

Creates a target group for ALB or NLB.

## Features

- Support for ALB (HTTP/HTTPS) and NLB (TCP/UDP/TLS)
- Multiple target types (instance, IP, Lambda, ALB)
- Configurable health checks
- Sticky sessions support
- Slow start for gradual traffic increase
- Load balancing algorithm selection
- Consistent naming and tagging

## Usage

### HTTP Target Group (ALB)

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-web"
  vpc_id   = module.vpc.vpc_id
  port     = 80
  protocol = "HTTP"

  health_check_path = "/health"
}
```

### HTTPS Target Group

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-api"
  vpc_id   = module.vpc.vpc_id
  port     = 443
  protocol = "HTTPS"

  health_check_path    = "/health"
  health_check_matcher = "200"
}
```

### TCP Target Group (NLB)

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-tcp"
  vpc_id   = module.vpc.vpc_id
  port     = 3306
  protocol = "TCP"

  health_check_protocol = "TCP"
}
```

### IP Target Type (Fargate, etc.)

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name        = "acme-prod-fargate"
  vpc_id      = module.vpc.vpc_id
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  health_check_path = "/health"
}
```

### With Sticky Sessions

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-web"
  vpc_id   = module.vpc.vpc_id
  port     = 80
  protocol = "HTTP"

  stickiness_enabled  = true
  stickiness_type     = "lb_cookie"
  stickiness_duration = 3600
}
```

### With Slow Start

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-web"
  vpc_id   = module.vpc.vpc_id
  port     = 80
  protocol = "HTTP"

  slow_start           = 120
  deregistration_delay = 30
}
```

### Complete Example with ALB

```hcl
module "target_group" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/target-group?ref=v1.0.0"

  name     = "acme-prod-web"
  vpc_id   = module.vpc.vpc_id
  port     = 80
  protocol = "HTTP"

  health_check_path                = "/health"
  health_check_interval            = 15
  health_check_timeout             = 5
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 3
  health_check_matcher             = "200-299"

  deregistration_delay          = 60
  load_balancing_algorithm_type = "least_outstanding_requests"

  tags = {
    Environment = "production"
  }
}

module "alb" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/alb?ref=v1.0.0"

  name               = "acme-prod-web"
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.id]

  create_https_listener           = true
  https_listener_certificate_arn  = aws_acm_certificate.main.arn
  https_listener_target_group_arn = module.target_group.arn
}

module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids

  target_group_arns = [module.target_group.arn]
  health_check_type = "ELB"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the target group | `string` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| port | Target port | `number` | n/a | yes |
| protocol | Protocol (HTTP, HTTPS, TCP, UDP, TCP_UDP, TLS) | `string` | n/a | yes |
| target_type | Target type (instance, ip, lambda, alb) | `string` | `"instance"` | no |
| health_check_enabled | Enable health checks | `bool` | `true` | no |
| health_check_path | Health check path | `string` | `"/"` | no |
| health_check_port | Health check port | `string` | `"traffic-port"` | no |
| health_check_protocol | Health check protocol | `string` | `""` | no |
| health_check_interval | Check interval in seconds | `number` | `30` | no |
| health_check_timeout | Check timeout in seconds | `number` | `5` | no |
| health_check_healthy_threshold | Healthy threshold | `number` | `3` | no |
| health_check_unhealthy_threshold | Unhealthy threshold | `number` | `3` | no |
| health_check_matcher | HTTP status codes | `string` | `"200-299"` | no |
| stickiness_enabled | Enable sticky sessions | `bool` | `false` | no |
| stickiness_type | Stickiness type | `string` | `"lb_cookie"` | no |
| stickiness_duration | Duration in seconds | `number` | `86400` | no |
| stickiness_cookie_name | Cookie name (app_cookie) | `string` | `""` | no |
| deregistration_delay | Deregistration delay | `number` | `300` | no |
| slow_start | Slow start duration | `number` | `0` | no |
| load_balancing_algorithm_type | Algorithm type | `string` | `"round_robin"` | no |
| lambda_multi_value_headers_enabled | Lambda headers | `bool` | `false` | no |
| proxy_protocol_v2 | Proxy protocol v2 (NLB) | `bool` | `false` | no |
| preserve_client_ip | Preserve client IP (NLB) | `bool` | `true` | no |
| connection_termination | Terminate connections (NLB) | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the target group |
| arn | The ARN of the target group |
| arn_suffix | ARN suffix for CloudWatch |
| name | The name of the target group |
| port | The port of the target group |
| protocol | The protocol of the target group |
| target_type | The target type |
| target_group_arn | Alias for arn |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- HTTP/HTTPS target groups support health check path and matcher.
- TCP/UDP target groups only support TCP health checks.
- Use `target_type = "ip"` for Fargate, ECS with awsvpc, or multi-account targets.
- Slow start gradually increases traffic to new targets.
- `least_outstanding_requests` algorithm is better for varying request durations.
