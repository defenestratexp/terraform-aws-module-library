# Redshift Cluster Module

Creates an Amazon Redshift cluster with optional subnet group and parameter group.

## Usage

### Single-Node Cluster

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "dc2.large"
  master_username    = "admin"
  master_password    = var.redshift_password

  tags = {
    Environment = "production"
  }
}
```

### Multi-Node Cluster

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"
  cluster_type       = "multi-node"
  number_of_nodes    = 3

  master_username = "admin"
  master_password = var.redshift_password

  tags = {
    Environment = "production"
  }
}
```

### With VPC Configuration

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  # Networking
  create_subnet_group    = true
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.redshift_sg.id]
  enhanced_vpc_routing   = true

  tags = {
    Environment = "production"
  }
}
```

### With KMS Encryption

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  encrypted  = true
  kms_key_id = module.kms_key.arn

  tags = {
    Environment = "production"
  }
}
```

### With Custom Parameter Group

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  create_parameter_group = true
  parameters = {
    require_ssl = {
      value = "true"
    }
    enable_user_activity_logging = {
      value = "true"
    }
    max_concurrency_scaling_clusters = {
      value = "1"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### With IAM Roles for S3 Access

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  iam_roles = [
    aws_iam_role.redshift_s3_access.arn,
    aws_iam_role.redshift_glue_access.arn,
  ]
  default_iam_role_arn = aws_iam_role.redshift_s3_access.arn

  tags = {
    Environment = "production"
  }
}
```

### With Logging to S3

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  logging = {
    enable        = true
    bucket_name   = module.logs_bucket.id
    s3_key_prefix = "redshift-logs/"
    log_exports   = ["connectionlog", "userlog", "useractivitylog"]
  }

  tags = {
    Environment = "production"
  }
}
```

### With Cross-Region Snapshot Copy

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  automated_snapshot_retention_period = 7

  snapshot_copy = {
    destination_region = "us-west-2"
    retention_period   = 7
  }

  tags = {
    Environment = "production"
  }
}
```

### Restore from Snapshot

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "restored-warehouse"
  node_type          = "ra3.xlplus"

  master_username = "admin"
  master_password = var.redshift_password

  snapshot_identifier         = "my-snapshot"
  snapshot_cluster_identifier = "original-cluster"

  tags = {
    Environment = "production"
  }
}
```

### Multi-AZ Deployment

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "ha-warehouse"
  node_type          = "ra3.xlplus"
  cluster_type       = "multi-node"
  number_of_nodes    = 2

  master_username = "admin"
  master_password = var.redshift_password

  multi_az = true

  create_subnet_group    = true
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.redshift_sg.id]

  tags = {
    Environment = "production"
  }
}
```

### With AQUA Enabled

```hcl
module "redshift" {
  source = "path/to/modules/redshift-cluster"

  cluster_identifier = "my-warehouse"
  node_type          = "ra3.4xlarge"
  cluster_type       = "multi-node"
  number_of_nodes    = 2

  master_username = "admin"
  master_password = var.redshift_password

  aqua_configuration_status = "enabled"

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Node Types**: DC2, RA3 (managed storage)
- **Cluster Types**: Single-node or multi-node
- **Encryption**: KMS encryption at rest
- **Networking**: VPC, subnet groups, enhanced VPC routing
- **Snapshots**: Automated, manual, cross-region copy
- **Logging**: Connection, user, user activity logs
- **AQUA**: Advanced Query Accelerator
- **Multi-AZ**: High availability deployment

## Node Types

| Type | vCPU | Memory | Storage | Use Case |
|------|------|--------|---------|----------|
| dc2.large | 2 | 15 GB | 160 GB SSD | Development |
| dc2.8xlarge | 32 | 244 GB | 2.56 TB SSD | Compute-intensive |
| ra3.xlplus | 4 | 32 GB | Managed | General purpose |
| ra3.4xlarge | 12 | 96 GB | Managed | Production |
| ra3.16xlarge | 48 | 384 GB | Managed | Large-scale |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_identifier | Cluster identifier | `string` | n/a | yes |
| node_type | Node type | `string` | n/a | yes |
| master_username | Master username | `string` | n/a | yes |
| master_password | Master password | `string` | n/a | yes |
| cluster_type | Cluster type | `string` | `"single-node"` | no |
| number_of_nodes | Number of nodes | `number` | `1` | no |
| database_name | Default database name | `string` | `"dev"` | no |
| port | Port number | `number` | `5439` | no |
| vpc_security_group_ids | Security group IDs | `list(string)` | `[]` | no |
| create_subnet_group | Create subnet group | `bool` | `false` | no |
| subnet_ids | Subnet IDs | `list(string)` | `[]` | no |
| publicly_accessible | Public access | `bool` | `false` | no |
| enhanced_vpc_routing | Enhanced VPC routing | `bool` | `false` | no |
| encrypted | Enable encryption | `bool` | `true` | no |
| kms_key_id | KMS key ID | `string` | `null` | no |
| create_parameter_group | Create parameter group | `bool` | `false` | no |
| parameters | Parameter group parameters | `map(object)` | `{}` | no |
| automated_snapshot_retention_period | Snapshot retention days | `number` | `1` | no |
| skip_final_snapshot | Skip final snapshot | `bool` | `false` | no |
| snapshot_copy | Cross-region snapshot copy | `object` | `null` | no |
| iam_roles | IAM role ARNs | `list(string)` | `[]` | no |
| logging | Logging configuration | `object` | `null` | no |
| aqua_configuration_status | AQUA status | `string` | `"auto"` | no |
| multi_az | Multi-AZ deployment | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Cluster identifier |
| arn | Cluster ARN |
| cluster_identifier | Cluster identifier |
| endpoint | Connection endpoint |
| dns_name | DNS name |
| database_name | Default database name |
| port | Port number |
| master_username | Master username |
| subnet_group_name | Subnet group name |
| parameter_group_name | Parameter group name |

## Considerations

- RA3 node types use managed storage (separate compute/storage)
- Multi-AZ requires RA3 node types
- AQUA requires RA3.4xlarge or larger
- Enhanced VPC routing forces all COPY/UNLOAD traffic through VPC
- Cross-region snapshot copy requires KMS key in destination region
- Automated snapshots are deleted when cluster is deleted
