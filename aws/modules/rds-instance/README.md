# RDS Instance Module

Creates a single RDS database instance with comprehensive configuration options.

## Usage

### Basic MySQL Instance

```hcl
module "mysql" {
  source = "path/to/modules/rds-instance"

  identifier     = "my-mysql-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  db_name           = "myapp"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]

  tags = {
    Environment = "development"
    Project     = "my-app"
  }
}
```

### PostgreSQL with Multi-AZ

```hcl
module "postgres" {
  source = "path/to/modules/rds-instance"

  identifier     = "my-postgres-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.r5.large"

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"

  db_name  = "myapp"
  multi_az = true

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]

  backup_retention_period = 14
  deletion_protection     = true

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### High-Performance IO2 Storage

```hcl
module "high_perf_db" {
  source = "path/to/modules/rds-instance"

  identifier     = "high-perf-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.r5.2xlarge"

  allocated_storage     = 500
  max_allocated_storage = 1000
  storage_type          = "io2"
  iops                  = 10000

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]
}
```

### With AWS-Managed Password

```hcl
module "mysql" {
  source = "path/to/modules/rds-instance"

  identifier     = "secure-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.medium"

  db_name                     = "myapp"
  manage_master_user_password = true

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]
}

# Access the secret ARN
output "db_secret_arn" {
  value = module.mysql.master_user_secret_arn
}
```

### With Custom Parameters

```hcl
module "mysql" {
  source = "path/to/modules/rds-instance"

  identifier     = "custom-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.medium"

  parameter_group_family = "mysql8.0"

  parameters = [
    {
      name  = "max_connections"
      value = "500"
    },
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

### With Performance Insights and Enhanced Monitoring

```hcl
module "monitored_db" {
  source = "path/to/modules/rds-instance"

  identifier     = "monitored-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.r5.large"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]

  # Enhanced Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 31

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}
```

### Restore from Snapshot

```hcl
module "restored_db" {
  source = "path/to/modules/rds-instance"

  identifier          = "restored-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.medium"
  snapshot_identifier = "my-snapshot-id"

  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.db_sg.id]
}
```

## Features

- **Multiple Engines**: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server
- **Storage Options**: gp2, gp3, io1, io2 with autoscaling
- **Encryption**: At-rest encryption with customer-managed KMS keys
- **High Availability**: Multi-AZ deployments
- **Backups**: Configurable retention and backup windows
- **Monitoring**: Enhanced monitoring and Performance Insights
- **CloudWatch Logs**: Export database logs to CloudWatch
- **Parameters**: Custom parameter group creation
- **Security**: VPC isolation, IAM authentication, managed passwords
- **Snapshots**: Create from and manage final snapshots

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | Unique identifier for the RDS instance | `string` | n/a | yes |
| engine | Database engine | `string` | n/a | yes |
| engine_version | Database engine version | `string` | n/a | yes |
| instance_class | Instance class | `string` | n/a | yes |
| allocated_storage | Allocated storage in GiB | `number` | `20` | no |
| max_allocated_storage | Maximum storage for autoscaling | `number` | `0` | no |
| storage_type | Storage type | `string` | `"gp3"` | no |
| iops | Provisioned IOPS | `number` | `null` | no |
| storage_throughput | Storage throughput in MiB/s | `number` | `null` | no |
| storage_encrypted | Enable storage encryption | `bool` | `true` | no |
| kms_key_id | KMS key ARN for encryption | `string` | `""` | no |
| db_name | Database name to create | `string` | `""` | no |
| username | Master username | `string` | `"admin"` | no |
| password | Master password | `string` | `""` | no |
| manage_master_user_password | Use AWS-managed password | `bool` | `true` | no |
| subnet_ids | Subnet IDs for DB subnet group | `list(string)` | `[]` | no |
| vpc_security_group_ids | Security group IDs | `list(string)` | `[]` | no |
| publicly_accessible | Make publicly accessible | `bool` | `false` | no |
| multi_az | Enable Multi-AZ | `bool` | `false` | no |
| backup_retention_period | Backup retention days | `number` | `7` | no |
| backup_window | Preferred backup window | `string` | `"03:00-04:00"` | no |
| maintenance_window | Preferred maintenance window | `string` | `"Mon:04:00-Mon:05:00"` | no |
| monitoring_interval | Enhanced monitoring interval | `number` | `0` | no |
| performance_insights_enabled | Enable Performance Insights | `bool` | `false` | no |
| parameter_group_family | Parameter group family | `string` | `""` | no |
| parameters | List of DB parameters | `list(object)` | `[]` | no |
| deletion_protection | Enable deletion protection | `bool` | `false` | no |
| skip_final_snapshot | Skip final snapshot | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The RDS instance ID |
| arn | The ARN of the RDS instance |
| identifier | The RDS instance identifier |
| endpoint | The connection endpoint |
| address | The hostname of the RDS instance |
| port | The database port |
| username | The master username |
| db_name | The name of the database |
| engine | The database engine |
| engine_version_actual | The actual engine version |
| hosted_zone_id | The hosted zone ID for Route53 |
| resource_id | The RDS resource ID |
| availability_zone | The availability zone |
| multi_az | Whether multi-AZ is enabled |
| master_user_secret_arn | ARN of the Secrets Manager secret |
| subnet_group_id | The DB subnet group ID |
| parameter_group_id | The DB parameter group ID |

## Engine Log Exports

| Engine | Available Logs |
|--------|---------------|
| MySQL | audit, error, general, slowquery |
| PostgreSQL | postgresql, upgrade |
| MariaDB | audit, error, general, slowquery |
| Oracle | alert, audit, listener, trace |
| SQL Server | agent, error |
