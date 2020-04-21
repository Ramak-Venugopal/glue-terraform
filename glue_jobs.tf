module "addresses" {
  source        = "./glue_job"
  name          = "deputy_stg"
  enabled       = local.account.glue_crawler_enabled ? 1 : 0
  glue_transfer = local.account.glue_transfer

  glue_bucket     = module.glue_api.glue_bucket
  data_dir        = module.glue_api.data_dir
  script_temp_dir = module.glue_api.glue_script_temp_dir

  glue_job_role        = module.glue_api.aws_iam_role_glue_job
  connection           = module.glue_api.aws_glue_connection
  glue_security_config = module.glue_api.aws_glue_security_configuration
  catalog_database     = module.glue_api.aws_glue_catalog_database
  rds_database         = aws_db_instance.api
}

module "datamigration" {
  source        = "./glue_job"
  name          = "deputy"
  enabled       = local.account.glue_crawler_enabled ? 1 : 0
  glue_transfer = local.account.glue_transfer

  glue_bucket     = module.glue_api.glue_bucket
  data_dir        = module.glue_api.data_dir
  script_temp_dir = module.glue_api.glue_script_temp_dir

  glue_job_role        = module.glue_api.aws_iam_role_glue_job
  connection           = module.glue_api.aws_glue_connection
  glue_security_config = module.glue_api.aws_glue_security_configuration
  catalog_database     = module.glue_api.aws_glue_catalog_database
  rds_database         = aws_db_instance.api
}
