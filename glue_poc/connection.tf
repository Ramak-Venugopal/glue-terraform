resource "aws_glue_connection" "connection" {
  count = var.enabled
  name  = var.name

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${var.db_instance.endpoint}/${var.db_instance.name}"
    PASSWORD            = var.db_password.secret_string
    USERNAME            = var.db_instance.username
  }

  physical_connection_requirements {
    availability_zone      = var.glue_subnet.availability_zone
    subnet_id              = var.glue_subnet.id
    security_group_id_list = [aws_security_group.glue[0].id]
  }
}

variable "db_password" {
  description = "Database password, in the form of an aws_secretsmanager_secret_version"
}

output "aws_glue_connection" {
  value = concat(aws_glue_connection.connection, [""])[0]
}

resource "aws_glue_security_configuration" "config" {
  count = var.enabled
  name  = var.name

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "DISABLED"
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "DISABLED"
    }

    s3_encryption {
      s3_encryption_mode = "SSE-S3"
    }
  }
}

output "aws_glue_security_configuration" {
  value = concat(aws_glue_security_configuration.config, [""])[0]
}
