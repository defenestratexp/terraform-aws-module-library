# EC2 Instance Module

Creates a single EC2 instance with common configurations.

## Features

- Automatic AMI lookup (Amazon Linux 2023 by default) or specify custom AMI
- Root volume encryption by default
- IMDSv2 required by default (security best practice)
- Support for additional EBS volumes
- User data support (plain text or base64)
- IAM instance profile attachment
- Consistent naming and tagging

## Usage

### Basic Usage

```hcl
module "web_server" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/ec2-instance?ref=v1.0.0"

  name      = "acme-prod-web"
  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_ids = [module.web_sg.id]
}
```

### With SSH Key and Public IP

```hcl
module "bastion" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/ec2-instance?ref=v1.0.0"

  name      = "acme-prod-bastion"
  subnet_id = module.vpc.public_subnet_ids[0]

  instance_type               = "t3.small"
  key_name                    = "my-ssh-key"
  associate_public_ip_address = true
  security_group_ids          = [module.ssh_sg.id]

  tags = {
    Environment = "production"
    Role        = "bastion"
  }
}
```

### With Custom AMI and User Data

```hcl
module "app_server" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/ec2-instance?ref=v1.0.0"

  name      = "acme-prod-app"
  subnet_id = module.vpc.private_subnet_ids[0]
  ami_id    = "ami-0123456789abcdef0"

  instance_type      = "t3.medium"
  security_group_ids = [module.app_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
  EOF

  root_volume_size = 50
}
```

### With Ubuntu AMI

```hcl
module "ubuntu_server" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/ec2-instance?ref=v1.0.0"

  name      = "acme-prod-ubuntu"
  subnet_id = module.vpc.private_subnet_ids[0]

  ami_filter_name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  ami_owners      = ["099720109477"]  # Canonical

  security_group_ids = [module.app_sg.id]
}
```

### With Additional EBS Volumes

```hcl
module "database_server" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/ec2-instance?ref=v1.0.0"

  name      = "acme-prod-db"
  subnet_id = module.vpc.private_subnet_ids[0]

  instance_type      = "r5.large"
  security_group_ids = [module.db_sg.id]

  root_volume_size = 50

  additional_ebs_volumes = [
    {
      device_name = "/dev/sdf"
      volume_size = 500
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    },
    {
      device_name = "/dev/sdg"
      volume_size = 100
      volume_type = "gp3"
    }
  ]
}
```

### With IAM Instance Profile

```hcl
module "app_server" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/ec2-instance?ref=v1.0.0"

  name      = "acme-prod-app"
  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_ids   = [module.app_sg.id]
  iam_instance_profile = aws_iam_instance_profile.app.name
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the EC2 instance | `string` | n/a | yes |
| subnet_id | ID of the subnet to launch in | `string` | n/a | yes |
| ami_id | AMI ID (uses latest Amazon Linux 2023 if empty) | `string` | `""` | no |
| ami_filter_name | Name filter for AMI lookup | `string` | `"al2023-ami-*-x86_64"` | no |
| ami_owners | AMI owners for lookup | `list(string)` | `["amazon"]` | no |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| key_name | SSH key pair name | `string` | `""` | no |
| security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| iam_instance_profile | IAM instance profile name | `string` | `""` | no |
| user_data | User data script | `string` | `""` | no |
| user_data_base64 | Base64-encoded user data | `string` | `""` | no |
| user_data_replace_on_change | Recreate instance on user data change | `bool` | `false` | no |
| associate_public_ip_address | Assign public IP | `bool` | `null` | no |
| private_ip | Specific private IP | `string` | `null` | no |
| source_dest_check | Enable source/dest check | `bool` | `true` | no |
| root_volume_size | Root volume size in GB | `number` | `20` | no |
| root_volume_type | Root volume type | `string` | `"gp3"` | no |
| root_volume_encrypted | Encrypt root volume | `bool` | `true` | no |
| root_volume_kms_key_id | KMS key for root volume | `string` | `""` | no |
| delete_on_termination | Delete root volume on terminate | `bool` | `true` | no |
| additional_ebs_volumes | Additional EBS volumes | `list(object)` | `[]` | no |
| monitoring | Enable detailed monitoring | `bool` | `false` | no |
| metadata_http_tokens | IMDSv2 token requirement | `string` | `"required"` | no |
| metadata_http_endpoint | Enable metadata endpoint | `string` | `"enabled"` | no |
| disable_api_termination | Enable termination protection | `bool` | `false` | no |
| instance_initiated_shutdown_behavior | Shutdown behavior | `string` | `"stop"` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the instance |
| arn | The ARN of the instance |
| instance_id | Alias for id |
| private_ip | Private IP address |
| public_ip | Public IP address (if applicable) |
| private_dns | Private DNS name |
| public_dns | Public DNS name (if applicable) |
| availability_zone | Availability zone |
| subnet_id | Subnet ID |
| vpc_security_group_ids | Attached security group IDs |
| ami_id | AMI ID used |
| instance_type | Instance type |
| instance_state | Instance state |
| root_volume_id | Root EBS volume ID |
| additional_volume_ids | Additional EBS volume IDs |

## Common AMI Filters

| OS | Filter | Owner |
|----|--------|-------|
| Amazon Linux 2023 | `al2023-ami-*-x86_64` | `amazon` |
| Amazon Linux 2 | `amzn2-ami-hvm-*-x86_64-gp2` | `amazon` |
| Ubuntu 22.04 | `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*` | `099720109477` |
| Ubuntu 20.04 | `ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*` | `099720109477` |
| Debian 12 | `debian-12-amd64-*` | `136693071363` |
| RHEL 9 | `RHEL-9*_HVM-*-x86_64-*` | `309956199498` |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Notes

- AMI changes are ignored in lifecycle to prevent unintended instance replacement.
- IMDSv2 is required by default for security. Set `metadata_http_tokens = "optional"` to allow IMDSv1.
- Root volume is encrypted by default using AWS managed keys.
- Use `user_data_replace_on_change = true` if you want instance recreation on user data updates.
