variable "enabled" {
  type        = number
  description = "Count for enabling and disabling resources in this module"
}

variable "default_tags" {
  type = map(string)
}

variable "glue_subnet" {}

variable "name" {
  description = "Connection name e.g. sirius-api"
  type        = string
}

output "glue_job" {
  value = concat(aws_iam_role.glue_job, [""])[0]
}
