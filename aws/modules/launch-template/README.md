# Launch Template Module

Creates a launch template for use with Auto Scaling Groups.

## Features

- Automatic AMI lookup or specify custom AMI
- Root volume encryption by default
- IMDSv2 required by default
- Support for additional block devices
- User data support
- IAM instance profile attachment
- Instance and volume tagging
- Consistent naming and tagging

## Usage

### Basic Usage

```hcl
module "launch_template" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/launch-template?ref=v1.0.0"

  name               = "acme-prod-web"
  instance_type      = "t3.small"
  security_group_ids = [module.web_sg.id]
}
```

### With Custom AMI and User Data

```hcl
module "launch_template" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/launch-template?ref=v1.0.0"

  name          = "acme-prod-app"
  ami_id        = "ami-0123456789abcdef0"
  instance_type = "t3.medium"
  key_name      = "my-ssh-key"

  security_group_ids        = [module.app_sg.id]
  iam_instance_profile_name = aws_iam_instance_profile.app.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
  EOF

  root_volume_size = 50

  instance_tags = {
    Role = "application"
  }
}
```

### With Additional Volumes

```hcl
module "launch_template" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/launch-template?ref=v1.0.0"

  name               = "acme-prod-data"
  instance_type      = "r5.large"
  security_group_ids = [module.data_sg.id]

  root_volume_size = 50

  additional_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_size = 500
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    }
  ]
}
```

### Integration with ASG

```hcl
module "launch_template" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/launch-template?ref=v1.0.0"

  name               = "acme-prod-web"
  instance_type      = "t3.small"
  security_group_ids = [module.web_sg.id]
}

module "asg" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/asg?ref=v1.0.0"

  name               = "acme-prod-web"
  launch_template_id = module.launch_template.id
  subnet_ids         = module.vpc.private_subnet_ids
  min_size           = 2
  max_size           = 10
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the launch template | `string` | n/a | yes |
| ami_id | AMI ID (uses latest Amazon Linux 2023 if empty) | `string` | `""` | no |
| ami_filter_name | Name filter for AMI lookup | `string` | `"al2023-ami-*-x86_64"` | no |
| ami_owners | AMI owners for lookup | `list(string)` | `["amazon"]` | no |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| key_name | SSH key pair name | `string` | `""` | no |
| security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| iam_instance_profile_name | IAM instance profile name | `string` | `""` | no |
| iam_instance_profile_arn | IAM instance profile ARN | `string` | `""` | no |
| user_data | User data script | `string` | `""` | no |
| user_data_base64 | Base64-encoded user data | `string` | `""` | no |
| root_volume_size | Root volume size in GB | `number` | `20` | no |
| root_volume_type | Root volume type | `string` | `"gp3"` | no |
| root_volume_encrypted | Encrypt root volume | `bool` | `true` | no |
| root_volume_kms_key_id | KMS key for root volume | `string` | `""` | no |
| root_volume_iops | Root volume IOPS | `number` | `null` | no |
| root_volume_throughput | Root volume throughput | `number` | `null` | no |
| delete_on_termination | Delete root volume on terminate | `bool` | `true` | no |
| additional_block_devices | Additional block devices | `list(object)` | `[]` | no |
| monitoring_enabled | Enable detailed monitoring | `bool` | `false` | no |
| metadata_http_tokens | IMDSv2 token requirement | `string` | `"required"` | no |
| metadata_http_endpoint | Enable metadata endpoint | `string` | `"enabled"` | no |
| metadata_http_put_response_hop_limit | IMDS hop limit | `number` | `1` | no |
| update_default_version | Update default version on change | `bool` | `true` | no |
| description | Template description | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |
| instance_tags | Tags for launched instances | `map(string)` | `{}` | no |
| volume_tags | Tags for created volumes | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the launch template |
| arn | The ARN of the launch template |
| name | The name of the launch template |
| latest_version | The latest version number |
| default_version | The default version number |
| launch_template | Map with id, name, version for ASG reference |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- Launch templates are versioned; set `update_default_version = true` to use latest on each change.
- Security groups are attached via network interfaces, not directly.
- User data is automatically base64 encoded if provided as plain text.
- IMDSv2 is required by default for security best practices.
