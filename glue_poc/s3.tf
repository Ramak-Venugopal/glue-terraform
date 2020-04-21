locals {
  glue_data_expire_folder = "glue_data_expire/"
}

resource "aws_s3_bucket" "glue" {
  count         = var.enabled
  bucket        = "${replace(terraform.workspace, "_", "-")}.glue.bucket"
  acl           = "private"
  force_destroy = false
  tags          = var.default_tags

  lifecycle_rule {
    id      = "Moved-Files"
    enabled = true
    prefix  = local.glue_data_expire_folder

    expiration {
      days = 14
    }
  }
}

output "glue_bucket" {
  value = concat(aws_s3_bucket.glue, [""])[0]
}

resource "aws_s3_bucket_policy" "glue" {
  count  = var.enabled
  bucket = aws_s3_bucket.glue[0].id
  policy = data.aws_iam_policy_document.glue[0].json
}

data "aws_iam_policy_document" "glue" {
  count     = var.enabled
  policy_id = "PutObjPolicy"

  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.glue[0].arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_object" "glue_data" {
  count                  = var.enabled
  key                    = "sirius_glue_data/"
  bucket                 = aws_s3_bucket.glue[0].id
  server_side_encryption = "AES256"
}

output "data_dir" {
  value       = concat(aws_s3_bucket_object.glue_data, [""])[0]
  description = "Directory to store the transfer files"
}

resource "aws_s3_bucket_object" "glue_data_expire" {
  count                  = var.enabled
  key                    = local.glue_data_expire_folder
  bucket                 = aws_s3_bucket.glue[0].id
  server_side_encryption = "AES256"
}

# Data processing script folders
resource "aws_s3_bucket_object" "glue_script_dir" {
  count                  = var.enabled
  key                    = "GlueScripts/"
  bucket                 = aws_s3_bucket.glue[0].id
  server_side_encryption = "AES256"
}

output "glue_script_dir" {
  value = concat(aws_s3_bucket_object.glue_script_dir, [""])[0]
}

resource "aws_s3_bucket_object" "glue_script_temp_dir" {
  count                  = var.enabled
  key                    = "GlueScriptsTempDir/"
  bucket                 = aws_s3_bucket.glue[0].id
  server_side_encryption = "AES256"
}

output "glue_script_temp_dir" {
  value = concat(aws_s3_bucket_object.glue_script_temp_dir, [""])[0]
}
