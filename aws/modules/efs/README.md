# EFS Module

Creates an Elastic File System (EFS) with mount targets, access points, and lifecycle policies.

## Usage

### Basic EFS

```hcl
module "efs" {
  source = "path/to/modules/efs"

  name       = "my-application-data"
  subnet_ids = ["subnet-abc123", "subnet-def456"]

  security_group_ids = [module.efs_security_group.id]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### EFS with Lifecycle Policies

```hcl
module "efs" {
  source = "path/to/modules/efs"

  name       = "my-archive-data"
  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [module.efs_sg.id]

  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_archive               = "AFTER_90_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
}
```

### High-Performance EFS

```hcl
module "efs" {
  source = "path/to/modules/efs"

  name             = "high-performance-fs"
  performance_mode = "maxIO"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 256

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.efs_sg.id]
}
```

### EFS with Access Points

```hcl
module "efs" {
  source = "path/to/modules/efs"

  name       = "shared-storage"
  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [module.efs_sg.id]

  access_points = {
    app1 = {
      posix_user = {
        gid = 1001
        uid = 1001
      }
      root_directory = {
        path = "/app1"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
    app2 = {
      posix_user = {
        gid = 1002
        uid = 1002
      }
      root_directory = {
        path = "/app2"
        creation_info = {
          owner_gid   = 1002
          owner_uid   = 1002
          permissions = "755"
        }
      }
    }
  }
}
```

### EFS with Custom KMS Encryption

```hcl
module "efs" {
  source = "path/to/modules/efs"

  name       = "encrypted-data"
  encrypted  = true
  kms_key_id = module.kms_key.arn

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.efs_sg.id]
}
```

## Features

- **Encryption**: At-rest encryption with AWS-managed or customer-managed KMS keys
- **Performance Modes**: generalPurpose (default) or maxIO for high-throughput workloads
- **Throughput Modes**: Bursting, provisioned, or elastic throughput
- **Lifecycle Policies**: Automatic transition to Infrequent Access and Archive storage classes
- **Mount Targets**: Create mount targets in multiple subnets/AZs
- **Access Points**: Application-specific entry points with POSIX user/group enforcement
- **Backup Integration**: AWS Backup integration enabled by default
- **Security**: TLS enforcement via file system policy by default

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the EFS file system | `string` | n/a | yes |
| performance_mode | Performance mode (generalPurpose or maxIO) | `string` | `"generalPurpose"` | no |
| throughput_mode | Throughput mode (bursting, provisioned, or elastic) | `string` | `"bursting"` | no |
| provisioned_throughput_in_mibps | Provisioned throughput in MiB/s | `number` | `null` | no |
| encrypted | Enable encryption at rest | `bool` | `true` | no |
| kms_key_id | KMS key ID for encryption | `string` | `""` | no |
| lifecycle_policy | Lifecycle policy configuration | `object` | `{}` | no |
| subnet_ids | List of subnet IDs for mount targets | `list(string)` | `[]` | no |
| security_group_ids | List of security group IDs for mount targets | `list(string)` | `[]` | no |
| access_points | Map of access point configurations | `map(object)` | `{}` | no |
| enable_backup | Enable automatic backups via AWS Backup | `bool` | `true` | no |
| file_system_policy | JSON policy document for the file system | `string` | `""` | no |
| deny_nonsecure_transport | Deny access via non-TLS connections | `bool` | `true` | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the EFS file system |
| arn | The ARN of the EFS file system |
| dns_name | The DNS name for the EFS file system |
| mount_target_ids | Map of subnet ID to mount target ID |
| mount_target_dns_names | Map of subnet ID to mount target DNS name |
| mount_target_network_interface_ids | Map of subnet ID to mount target network interface ID |
| access_point_ids | Map of access point name to access point ID |
| access_point_arns | Map of access point name to access point ARN |
| size_in_bytes | The current size of the file system in bytes |

## Lifecycle Policy Values

### transition_to_ia
- `AFTER_7_DAYS`
- `AFTER_14_DAYS`
- `AFTER_30_DAYS`
- `AFTER_60_DAYS`
- `AFTER_90_DAYS`
- `AFTER_1_DAY`

### transition_to_archive
- `AFTER_1_DAY`
- `AFTER_7_DAYS`
- `AFTER_14_DAYS`
- `AFTER_30_DAYS`
- `AFTER_60_DAYS`
- `AFTER_90_DAYS`
- `AFTER_180_DAYS`
- `AFTER_270_DAYS`
- `AFTER_365_DAYS`

### transition_to_primary_storage_class
- `AFTER_1_ACCESS`
