resource "aws_iam_role" "glue_job" {
  count              = var.enabled
  name_prefix        = "GlueJobRole"
  description        = "Role for the Sirius Glue jobs"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json

  lifecycle {
    create_before_destroy = true
  }
}

output "aws_iam_role_glue_job" {
  value = concat(aws_iam_role.glue_job, [""])[0]
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  count      = var.enabled
  role       = aws_iam_role.glue_job[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "policy" {
  count       = var.enabled
  name_prefix = "GlueJobAccess"
  policy      = data.aws_iam_policy_document.glue_access[0].json
}

data "aws_iam_policy_document" "glue_access" {
  count = var.enabled
  statement {
    sid = "GlueExportAccess"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:PutObject",
      "kms:Encrypt",
      "kms:Decrypt"
    ]

    resources = [
      data.aws_kms_alias.s3.arn,
      aws_s3_bucket.glue[0].arn,
      "${aws_s3_bucket.glue[0].arn}/*",
    ]
  }
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

resource "aws_iam_role_policy_attachment" "export_access" {
  count      = var.enabled
  role       = aws_iam_role.glue_job[0].name
  policy_arn = aws_iam_policy.policy[0].arn
}
