resource "aws_iam_role" "crawler" {
  count              = var.enabled
  name_prefix        = "GlueServiceRole-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "crawler" {
  count      = var.enabled
  role       = aws_iam_role.crawler[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
