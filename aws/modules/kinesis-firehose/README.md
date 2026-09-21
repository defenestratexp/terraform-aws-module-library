# Kinesis Firehose Module

Creates an Amazon Kinesis Data Firehose delivery stream with various destination options.

## Usage

### S3 Destination

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "logs-to-s3"
  destination = "extended_s3"

  s3_configuration = {
    bucket_arn         = module.s3_bucket.arn
    role_arn           = aws_iam_role.firehose.arn
    prefix             = "logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/!{firehose:error-output-type}/"
    buffering_size     = 64
    buffering_interval = 60
    compression_format = "GZIP"
  }

  tags = {
    Environment = "production"
  }
}
```

### S3 with Parquet Conversion

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "events-to-parquet"
  destination = "extended_s3"

  s3_configuration = {
    bucket_arn         = module.s3_bucket.arn
    role_arn           = aws_iam_role.firehose.arn
    prefix             = "events/"
    buffering_size     = 128
    buffering_interval = 300
    compression_format = "UNCOMPRESSED"  # Parquet handles compression
  }

  data_format_conversion = {
    enabled = true
    input_format_configuration = {
      deserializer = {
        type = "OPENX_JSON"
      }
    }
    output_format_configuration = {
      serializer = {
        type = "PARQUET"
        parameters = {
          compression = "SNAPPY"
        }
      }
    }
    schema_configuration = {
      database_name = module.glue_database.name
      table_name    = aws_glue_catalog_table.events.name
      role_arn      = aws_iam_role.firehose.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### S3 with Lambda Transformation

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "transformed-logs"
  destination = "extended_s3"

  s3_configuration = {
    bucket_arn         = module.s3_bucket.arn
    role_arn           = aws_iam_role.firehose.arn
    prefix             = "processed/"
    buffering_size     = 64
    buffering_interval = 60
  }

  processing_configuration = {
    enabled = true
    processors = [
      {
        type = "Lambda"
        parameters = [
          {
            parameter_name  = "LambdaArn"
            parameter_value = "${module.transform_lambda.arn}:$LATEST"
          },
          {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = "1"
          },
          {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = "60"
          }
        ]
      }
    ]
  }

  tags = {
    Environment = "production"
  }
}
```

### Kinesis Stream Source

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "stream-to-s3"
  destination = "extended_s3"

  kinesis_source = {
    kinesis_stream_arn = module.kinesis_stream.arn
    role_arn           = aws_iam_role.firehose_kinesis.arn
  }

  s3_configuration = {
    bucket_arn         = module.s3_bucket.arn
    role_arn           = aws_iam_role.firehose.arn
    prefix             = "streamed/"
    buffering_size     = 64
    buffering_interval = 60
  }

  tags = {
    Environment = "production"
  }
}
```

### Redshift Destination

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "events-to-redshift"
  destination = "redshift"

  redshift_configuration = {
    cluster_jdbcurl    = "jdbc:redshift://${module.redshift.endpoint}/${module.redshift.database_name}"
    username           = "firehose_user"
    password           = var.redshift_password
    role_arn           = aws_iam_role.firehose.arn
    data_table_name    = "events"
    copy_options       = "json 'auto' gzip"
    retry_duration     = 3600

    s3_backup = {
      bucket_arn         = module.staging_bucket.arn
      prefix             = "redshift-staging/"
      buffering_size     = 64
      buffering_interval = 60
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### OpenSearch Destination

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "logs-to-opensearch"
  destination = "opensearch"

  opensearch_configuration = {
    domain_arn            = module.opensearch.arn
    role_arn              = aws_iam_role.firehose.arn
    index_name            = "logs"
    index_rotation_period = "OneDay"
    buffering_size        = 5
    buffering_interval    = 60
    s3_backup_mode        = "FailedDocumentsOnly"

    s3_backup = {
      bucket_arn = module.backup_bucket.arn
      role_arn   = aws_iam_role.firehose.arn
      prefix     = "opensearch-failed/"
    }

    vpc_config = {
      subnet_ids         = module.vpc.private_subnet_ids
      security_group_ids = [module.firehose_sg.id]
      role_arn           = aws_iam_role.firehose_vpc.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### HTTP Endpoint Destination

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "events-to-datadog"
  destination = "http_endpoint"

  http_endpoint_configuration = {
    url        = "https://aws-kinesis-http-intake.logs.datadoghq.com/v1/input"
    name       = "Datadog"
    access_key = var.datadog_api_key
    role_arn   = aws_iam_role.firehose.arn

    buffering_size     = 4
    buffering_interval = 60
    s3_backup_mode     = "FailedDataOnly"

    s3_backup = {
      bucket_arn = module.backup_bucket.arn
      prefix     = "datadog-failed/"
    }

    request_configuration = {
      content_encoding = "GZIP"
      common_attributes = [
        {
          name  = "env"
          value = "production"
        }
      ]
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### With Server-Side Encryption

```hcl
module "firehose" {
  source = "path/to/modules/kinesis-firehose"

  name        = "encrypted-stream"
  destination = "extended_s3"

  server_side_encryption = {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = module.kms_key.arn
  }

  s3_configuration = {
    bucket_arn = module.s3_bucket.arn
    role_arn   = aws_iam_role.firehose.arn
    kms_key_arn = module.kms_key.arn
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Multiple Destinations**: S3, Redshift, OpenSearch, HTTP endpoints
- **Data Transformation**: Lambda processing
- **Format Conversion**: JSON to Parquet/ORC
- **Buffering**: Configurable size and time intervals
- **Encryption**: Server-side encryption with KMS
- **Error Handling**: S3 backup for failed records

## Buffering Guidelines

| Use Case | Size (MB) | Interval (sec) |
|----------|-----------|----------------|
| Near real-time | 1-5 | 60 |
| Balanced | 64 | 300 |
| Cost optimized | 128 | 900 |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Delivery stream name | `string` | n/a | yes |
| destination | Destination type | `string` | n/a | yes |
| kinesis_source | Kinesis stream source | `object` | `null` | no |
| s3_configuration | S3 destination config | `object` | `null` | no |
| redshift_configuration | Redshift destination config | `object` | `null` | no |
| opensearch_configuration | OpenSearch destination config | `object` | `null` | no |
| http_endpoint_configuration | HTTP endpoint config | `object` | `null` | no |
| processing_configuration | Lambda transformation | `object` | `null` | no |
| data_format_conversion | Parquet/ORC conversion | `object` | `null` | no |
| server_side_encryption | SSE configuration | `object` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Delivery stream ID |
| arn | Delivery stream ARN |
| name | Delivery stream name |
| destination | Destination type |

## Considerations

- IAM roles need appropriate permissions for each destination
- Lambda transformation adds latency and cost
- Parquet conversion requires Glue Data Catalog schema
- OpenSearch VPC delivery requires VPC endpoint
- HTTP endpoints must return 200 for successful delivery
- S3 prefix supports dynamic partitioning with timestamp expressions
