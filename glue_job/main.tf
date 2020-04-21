resource "aws_s3_bucket_object" "script" {
  count                  = var.enabled
  key                    = "GlueScripts/${var.name}.py"
  bucket                 = var.glue_bucket.bucket
  server_side_encryption = "AES256"
  content = templatefile(
    "${path.module}/scripts/${var.name}.template.py",
    {
      bucketpath         = "s3://${var.glue_bucket.bucket}/${var.data_dir.id}${var.name}/"
      account            = terraform.workspace
      database           = var.rds_database.name
      catalog_database   = var.catalog_database.name
      source_bucket      = var.glue_bucket.bucket
      destination_bucket = "mojap-land"
      glue_transfer      = var.glue_transfer
    }
  )
}

resource "aws_glue_job" "job" {
  count                  = var.enabled
  name                   = "${var.name}-${terraform.workspace}"
  role_arn               = var.glue_job_role.arn
  security_configuration = var.glue_security_config.id
  connections            = [var.connection.name]
  glue_version           = "1.0"
  timeout                = 60

  command {
    name            = "glueetl"
    script_location = "s3://${var.glue_bucket.id}/${aws_s3_bucket_object.script[0].id}"
    python_version  = 3
  }

  default_arguments = {
    "--encryption-type"     = "sse-s3"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--job-language"        = "python"
    "--TempDir"             = "s3://${var.glue_bucket.id}/${var.script_temp_dir.id}"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_glue_trigger" "trigger" {
  count    = var.enabled
  name     = "${var.name}-${terraform.workspace}"
  schedule = var.cron
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.job[0].name
  }
}

variable "enabled" {
  type = number
}

variable "name" {
  type        = string
  description = "Job name"
}

variable "glue_security_config" {
  description = "A glue security config object"
}

variable "connection" {
  description = "A glue connection object"
}

variable "catalog_database" {
  description = "A catalog database object"
}

variable "data_dir" {
  description = "A S3 bucket object where the script is stored"
}

variable "script_temp_dir" {
  description = "A S3 bucket object where processing is stored"
}

variable "glue_bucket" {
  description = "A S3 bucket to store the glue job in"
}

variable "glue_job_role" {
  description = "An aws_iam_role that gives the glue job permissions to run"
}

variable "rds_database" {
  description = "A aws_rds_instance object that contains the name of the database you want to connect to"
}

variable "cron" {
  type        = string
  description = "Cron time to trigger the job"
  default     = "cron(00 03 * * ? *)"
}

variable "glue_transfer" {
  type        = bool
  description = "Whether to transfer to the MOJ analytical platform"
  default     = false
}
