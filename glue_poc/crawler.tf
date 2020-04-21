resource "aws_glue_crawler" "crawler" {
  count         = var.enabled
  name          = var.name
  database_name = aws_glue_catalog_database.database[0].name
  role          = aws_iam_role.crawler[0].arn
  schedule      = "cron(00 04 ? * WED *)"

  jdbc_target {
    connection_name = aws_glue_connection.connection[0].name
    path            = "${var.db_instance.name}/%"
  }
}

resource "aws_glue_catalog_database" "database" {
  count       = var.enabled
  name        = var.name
  description = "${var.name} catalogue"
}

output "aws_glue_catalog_database" {
  value = concat(aws_glue_catalog_database.database, [""])[0]
}
