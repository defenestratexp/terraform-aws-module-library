# Glue Catalog Database Module

Creates an AWS Glue Data Catalog database with optional tables for use with Athena, Redshift Spectrum, and EMR.

## Usage

### Basic Database

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name        = "analytics"
  description = "Analytics data lake database"
}
```

### Database with S3 Location

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name         = "data_lake"
  description  = "Data lake database"
  location_uri = "s3://my-data-lake-bucket/databases/data_lake/"
}
```

### Database with Tables

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name        = "events"
  description = "Event tracking database"

  tables = {
    page_views = {
      description = "Page view events"
      table_type  = "EXTERNAL_TABLE"

      storage_descriptor = {
        location      = "s3://my-bucket/events/page_views/"
        input_format  = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

        ser_de_info = {
          serialization_library = "org.openx.data.jsonserde.JsonSerDe"
        }

        columns = [
          { name = "event_id", type = "string" },
          { name = "user_id", type = "string" },
          { name = "page_url", type = "string" },
          { name = "timestamp", type = "timestamp" },
        ]
      }

      partition_keys = [
        { name = "year", type = "string" },
        { name = "month", type = "string" },
        { name = "day", type = "string" },
      ]
    }
  }
}
```

### Parquet Table

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name = "warehouse"

  tables = {
    orders = {
      description = "Order data"
      table_type  = "EXTERNAL_TABLE"

      parameters = {
        "classification"        = "parquet"
        "parquet.compression"   = "SNAPPY"
      }

      storage_descriptor = {
        location      = "s3://my-bucket/warehouse/orders/"
        input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

        ser_de_info = {
          serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
          parameters = {
            "serialization.format" = "1"
          }
        }

        columns = [
          { name = "order_id", type = "string" },
          { name = "customer_id", type = "string" },
          { name = "total_amount", type = "decimal(10,2)" },
          { name = "created_at", type = "timestamp" },
        ]
      }

      partition_keys = [
        { name = "dt", type = "string" },
      ]
    }
  }
}
```

### CSV Table

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name = "imports"

  tables = {
    customers = {
      description = "Customer data imports"
      table_type  = "EXTERNAL_TABLE"

      parameters = {
        "skip.header.line.count" = "1"
        "classification"         = "csv"
      }

      storage_descriptor = {
        location      = "s3://my-bucket/imports/customers/"
        input_format  = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

        ser_de_info = {
          serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
          parameters = {
            "separatorChar" = ","
            "quoteChar"     = "\""
          }
        }

        columns = [
          { name = "id", type = "string" },
          { name = "name", type = "string" },
          { name = "email", type = "string" },
        ]
      }
    }
  }
}
```

### Resource Link to Another Account

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name        = "shared_analytics"
  description = "Link to shared analytics database"

  target_database = {
    catalog_id    = "123456789012"
    database_name = "analytics"
    region        = "us-east-1"
  }
}
```

### With Lake Formation Permissions

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name        = "secure_data"
  description = "Database with Lake Formation permissions"

  create_table_default_permissions = [
    {
      permissions = ["ALL"]
      principal = {
        data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
      }
    }
  ]
}
```

### Multiple Tables

```hcl
module "glue_database" {
  source = "path/to/modules/glue-catalog-database"

  name = "logs"

  tables = {
    application_logs = {
      storage_descriptor = {
        location      = "s3://logs-bucket/application/"
        input_format  = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        ser_de_info = {
          serialization_library = "org.openx.data.jsonserde.JsonSerDe"
        }
        columns = [
          { name = "timestamp", type = "timestamp" },
          { name = "level", type = "string" },
          { name = "message", type = "string" },
        ]
      }
      partition_keys = [
        { name = "year", type = "string" },
        { name = "month", type = "string" },
      ]
    }

    access_logs = {
      storage_descriptor = {
        location      = "s3://logs-bucket/access/"
        input_format  = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        ser_de_info = {
          serialization_library = "org.apache.hadoop.hive.serde2.RegexSerDe"
          parameters = {
            "input.regex" = "^(\\S+) \\S+ \\S+ \\[([^\\]]+)\\] \"([^\"]+)\" (\\d+) (\\d+)$"
          }
        }
        columns = [
          { name = "ip", type = "string" },
          { name = "timestamp", type = "string" },
          { name = "request", type = "string" },
          { name = "status", type = "int" },
          { name = "size", type = "int" },
        ]
      }
    }
  }
}
```

## Features

- **Database Management**: Create and configure Glue catalog databases
- **Table Definitions**: Define table schemas for Athena/Spectrum
- **Multiple Formats**: JSON, Parquet, ORC, CSV, custom SerDe
- **Partitioning**: Define partition keys for efficient querying
- **Resource Links**: Link to databases in other accounts
- **Lake Formation**: Configure default table permissions

## Common SerDe Libraries

| Format | Serialization Library |
|--------|----------------------|
| JSON | `org.openx.data.jsonserde.JsonSerDe` |
| Parquet | `org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe` |
| ORC | `org.apache.hadoop.hive.ql.io.orc.OrcSerde` |
| CSV | `org.apache.hadoop.hive.serde2.OpenCSVSerde` |
| Regex | `org.apache.hadoop.hive.serde2.RegexSerDe` |
| CloudTrail | `com.amazon.emr.hive.serde.CloudTrailSerde` |

## Glue Data Types

| Type | Description |
|------|-------------|
| `string` | Variable-length character string |
| `int`, `bigint` | Integer types |
| `double`, `float` | Floating-point types |
| `decimal(p,s)` | Fixed-point decimal |
| `boolean` | True/false |
| `timestamp` | Date and time |
| `date` | Date only |
| `array<type>` | Array of elements |
| `map<key,value>` | Key-value pairs |
| `struct<...>` | Nested structure |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Database name | `string` | n/a | yes |
| description | Database description | `string` | `null` | no |
| location_uri | S3 location | `string` | `null` | no |
| parameters | Database parameters | `map(string)` | `{}` | no |
| catalog_id | Glue catalog ID | `string` | `null` | no |
| target_database | Resource link target | `object` | `null` | no |
| create_table_default_permissions | Lake Formation permissions | `list(object)` | `null` | no |
| tables | Map of tables to create | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Database catalog ID and name |
| arn | Database ARN |
| name | Database name |
| catalog_id | Catalog ID |
| table_arns | Map of table ARNs |
| table_ids | Map of table IDs |

## Considerations

- Database names must be lowercase
- Table schemas define metadata only - data lives in S3
- Partitions must be added separately (Glue crawler or `MSCK REPAIR TABLE`)
- Resource links require Lake Formation permissions
- SerDe must match the actual data format
