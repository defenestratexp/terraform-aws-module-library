# RDS Aurora Module

Creates an Aurora cluster with configurable instances, supporting both provisioned and serverless v2 configurations.

## Usage

### Basic Aurora MySQL Cluster

```hcl
module "aurora_mysql" {
  source = "path/to/modules/rds-aurora"

  cluster_identifier = "my-aurora-mysql"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"

  instance_count = 2
  instance_class = "db.r5.large"

  database_name = "myapp"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Aurora PostgreSQL with Serverless v2

```hcl
module "aurora_postgres" {
  source = "path/to/modules/rds-aurora"

  cluster_identifier = "my-aurora-postgres"
  engine             = "aurora-postgresql"
  engine_version     = "15.4"

  instance_count = 2

  serverless_v2_scaling = {
    min_capacity = 0.5
    max_capacity = 16
  }

  database_name = "myapp"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]

  tags = {
    Environment = "production"
  }
}
```

### High-Availability Production Cluster

```hcl
module "aurora_prod" {
  source = "path/to/modules/rds-aurora"

  cluster_identifier = "production-aurora"
  engine             = "aurora-postgresql"
  engine_version     = "15.4"

  instance_count = 3
  instance_class = "db.r6g.2xlarge"

  database_name = "production"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]

  # High durability settings
  backup_retention_period = 35
  deletion_protection     = true
  skip_final_snapshot     = false

  # Monitoring
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true
  performance_insights_retention_period = 31

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "production"
    Critical    = "true"
  }
}
```

### Aurora with Custom Parameters

```hcl
module "aurora_custom" {
  source = "path/to/modules/rds-aurora"

  cluster_identifier = "custom-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"

  instance_count = 2
  instance_class = "db.r5.large"

  cluster_parameter_group_family = "aurora-mysql8.0"
  cluster_parameters = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "character_set_client"
      value = "utf8mb4"
    }
  ]

  db_parameter_group_family = "aurora-mysql8.0"
  db_parameters = [
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "2"
    }
  ]

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]
}
```

### Aurora I/O-Optimized Storage

```hcl
module "aurora_io_optimized" {
  source = "path/to/modules/rds-aurora"

  cluster_identifier = "io-optimized-aurora"
  engine             = "aurora-postgresql"
  engine_version     = "15.4"

  instance_count = 2
  instance_class = "db.r6g.large"

  storage_type      = "aurora-iopt1"
  allocated_storage = 100

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]
}
```

### Restore from Snapshot

```hcl
module "restored_aurora" {
  source = "path/to/modules/rds-aurora"

  cluster_identifier  = "restored-aurora"
  engine              = "aurora-postgresql"
  engine_version      = "15.4"
  snapshot_identifier = "my-snapshot-id"

  instance_count = 2
  instance_class = "db.r5.large"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]
}
```

## Features

- **Aurora MySQL and PostgreSQL**: Support for both engines
- **Serverless v2**: Auto-scaling capacity with serverless v2
- **Multi-Instance**: Configurable number of instances with automatic promotion tiers
- **I/O-Optimized Storage**: Support for Aurora I/O-Optimized storage class
- **Encryption**: At-rest encryption with customer-managed KMS keys
- **AWS-Managed Passwords**: Secrets Manager integration for credentials
- **Backups**: Configurable retention and backup windows
- **Monitoring**: Enhanced monitoring and Performance Insights
- **CloudWatch Logs**: Export database logs to CloudWatch
- **Parameters**: Custom cluster and DB parameter groups
- **Global Database**: Support for Aurora Global Database

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_identifier | Unique identifier for the cluster | `string` | n/a | yes |
| engine | Aurora engine (aurora-mysql or aurora-postgresql) | `string` | n/a | yes |
| engine_version | Aurora engine version | `string` | n/a | yes |
| instance_count | Number of instances | `number` | `2` | no |
| instance_class | Instance class | `string` | `"db.r5.large"` | no |
| serverless_v2_scaling | Serverless v2 scaling configuration | `object` | `null` | no |
| storage_encrypted | Enable storage encryption | `bool` | `true` | no |
| kms_key_id | KMS key ARN for encryption | `string` | `""` | no |
| storage_type | Storage type (aurora or aurora-iopt1) | `string` | `"aurora"` | no |
| database_name | Database name to create | `string` | `""` | no |
| master_username | Master username | `string` | `"admin"` | no |
| manage_master_user_password | Use AWS-managed password | `bool` | `true` | no |
| subnet_ids | Subnet IDs for DB subnet group | `list(string)` | `[]` | no |
| vpc_security_group_ids | Security group IDs | `list(string)` | `[]` | no |
| backup_retention_period | Backup retention days | `number` | `7` | no |
| monitoring_interval | Enhanced monitoring interval | `number` | `0` | no |
| performance_insights_enabled | Enable Performance Insights | `bool` | `false` | no |
| cluster_parameter_group_family | Cluster parameter group family | `string` | `""` | no |
| cluster_parameters | Cluster parameters | `list(object)` | `[]` | no |
| db_parameter_group_family | DB parameter group family | `string` | `""` | no |
| db_parameters | DB instance parameters | `list(object)` | `[]` | no |
| deletion_protection | Enable deletion protection | `bool` | `false` | no |
| skip_final_snapshot | Skip final snapshot | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The Aurora cluster ID |
| cluster_arn | The ARN of the Aurora cluster |
| cluster_identifier | The cluster identifier |
| cluster_endpoint | The cluster writer endpoint |
| cluster_reader_endpoint | The cluster reader endpoint |
| cluster_port | The database port |
| cluster_database_name | The database name |
| cluster_master_username | The master username |
| cluster_engine | The database engine |
| cluster_engine_version_actual | The actual engine version |
| cluster_hosted_zone_id | The hosted zone ID for Route53 |
| master_user_secret_arn | ARN of the Secrets Manager secret |
| instance_ids | List of instance IDs |
| instance_endpoints | List of instance endpoints |
| writer_instance_id | The writer instance ID |
| writer_instance_endpoint | The writer instance endpoint |

## Engine Log Exports

| Engine | Available Logs |
|--------|---------------|
| aurora-mysql | audit, error, general, slowquery |
| aurora-postgresql | postgresql |
