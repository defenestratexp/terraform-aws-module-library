# EBS Volume Module

Creates a standalone EBS volume with optional EC2 instance attachment.

## Usage

### Basic GP3 Volume

```hcl
module "data_volume" {
  source = "path/to/modules/ebs-volume"

  name              = "my-data-volume"
  availability_zone = "us-east-1a"
  size              = 100

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### High-Performance IO2 Volume

```hcl
module "database_volume" {
  source = "path/to/modules/ebs-volume"

  name              = "database-volume"
  availability_zone = "us-east-1a"
  type              = "io2"
  size              = 500
  iops              = 16000

  tags = {
    Environment = "production"
    Application = "database"
  }
}
```

### Volume with Attachment

```hcl
module "app_volume" {
  source = "path/to/modules/ebs-volume"

  name              = "app-data-volume"
  availability_zone = data.aws_instance.app.availability_zone
  size              = 50

  attach_to_instance = aws_instance.app.id
  device_name        = "/dev/xvdf"
}
```

### Volume from Snapshot

```hcl
module "restored_volume" {
  source = "path/to/modules/ebs-volume"

  name              = "restored-volume"
  availability_zone = "us-east-1a"
  snapshot_id       = "snap-0123456789abcdef0"

  attach_to_instance = aws_instance.app.id
  device_name        = "/dev/xvdg"
}
```

### Multi-Attach IO2 Volume

```hcl
module "shared_volume" {
  source = "path/to/modules/ebs-volume"

  name              = "shared-io2-volume"
  availability_zone = "us-east-1a"
  type              = "io2"
  size              = 100
  iops              = 3000

  multi_attach_enabled = true
}
```

### Volume with Custom KMS Encryption

```hcl
module "encrypted_volume" {
  source = "path/to/modules/ebs-volume"

  name              = "encrypted-volume"
  availability_zone = "us-east-1a"
  size              = 100

  encrypted  = true
  kms_key_id = module.kms_key.arn
}
```

## Features

- **Volume Types**: Support for gp2, gp3, io1, io2, sc1, st1, and standard
- **Performance**: Configurable IOPS and throughput for supported volume types
- **Encryption**: At-rest encryption with AWS-managed or customer-managed KMS keys
- **Snapshots**: Create volumes from existing snapshots
- **Multi-Attach**: Support for io1/io2 multi-attach for shared storage
- **Attachment**: Optional automatic attachment to EC2 instances
- **Final Snapshot**: Option to create snapshot on volume destruction

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name tag for the EBS volume | `string` | n/a | yes |
| availability_zone | Availability zone for the volume | `string` | n/a | yes |
| size | Size of the volume in GiB | `number` | `8` | no |
| type | Volume type | `string` | `"gp3"` | no |
| iops | IOPS for gp3, io1, or io2 volumes | `number` | `null` | no |
| throughput | Throughput in MiB/s for gp3 volumes | `number` | `null` | no |
| encrypted | Enable encryption | `bool` | `true` | no |
| kms_key_id | KMS key ID for encryption | `string` | `""` | no |
| snapshot_id | Snapshot ID to create volume from | `string` | `""` | no |
| multi_attach_enabled | Enable multi-attach (io1/io2 only) | `bool` | `false` | no |
| attach_to_instance | EC2 instance ID to attach to | `string` | `""` | no |
| device_name | Device name for attachment | `string` | `"/dev/xvdf"` | no |
| force_detach | Force detach on destroy | `bool` | `false` | no |
| stop_instance_before_detaching | Stop instance before detaching | `bool` | `false` | no |
| final_snapshot | Create final snapshot on destroy | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the EBS volume |
| arn | The ARN of the EBS volume |
| availability_zone | The availability zone of the volume |
| size | The size of the volume in GiB |
| type | The type of the volume |
| iops | The IOPS of the volume |
| throughput | The throughput of the volume in MiB/s |
| encrypted | Whether the volume is encrypted |
| attachment_instance_id | The instance ID the volume is attached to |
| attachment_device_name | The device name (if attached) |

## Volume Type Specifications

| Type | Use Case | IOPS Range | Throughput |
|------|----------|------------|------------|
| gp3 | General purpose SSD | 3,000-16,000 | 125-1,000 MiB/s |
| gp2 | General purpose SSD | 100-16,000 (burst) | Up to 250 MiB/s |
| io2 | High-performance SSD | 100-64,000 | Up to 1,000 MiB/s |
| io1 | High-performance SSD | 100-64,000 | Up to 1,000 MiB/s |
| st1 | Throughput HDD | N/A | Up to 500 MiB/s |
| sc1 | Cold HDD | N/A | Up to 250 MiB/s |
| standard | Magnetic | N/A | 40-90 MiB/s |
