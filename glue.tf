
module "poc-datamigration" {
  source  = "./glue_poc"
  enabled = local.account.glue_crawler_enabled ? 1 : 0
  name    = "poc-${terraform.workspace}"

  db_instance           = aws_db_instance.api
  db_password           = data.aws_secretsmanager_secret_version.rds_api
  vpc                   = data.aws_vpc.sirius
  glue_subnet           = data.aws_subnet.private[0]
  rds_security_group_id = aws_security_group.rds_api.id
  default_tags          = local.default_tags
}