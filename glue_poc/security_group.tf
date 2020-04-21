resource "aws_security_group" "glue" {
  count                  = var.enabled
  name_prefix            = "rds-glue-connection-${terraform.workspace}"
  description            = "Glue Connection"
  vpc_id                 = var.vpc.id
  revoke_rules_on_delete = true
  tags                   = merge({ Name = "rds-glue-connection" }, var.default_tags)
}

output "security_group" {
  value = concat(aws_security_group.glue, [""])[0]
}

variable "vpc" {}

resource "aws_security_group_rule" "rds_outbound" {
  count                    = var.enabled
  description              = "Glue to RDS ${var.db_instance.identifier}"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.glue[0].id
  source_security_group_id = var.rds_security_group_id
}

variable "db_instance" {
  description = "RDS Name"
}

variable "rds_security_group_id" {
  type        = string
  description = "Security Group ID for the RDS instance"
}

# # Glue jobs require an egress on all ports to function
# # Fixes the following error:
# # At least one security group must open all ingress ports.
# # To limit traffic, the source security group in your inbound rule can be
# # restricted to the same security group
resource "aws_security_group_rule" "glue_self_outbound" {
  count             = var.enabled
  description       = "Allow access to self"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.glue[0].id
  self              = true
}

# # Glue jobs require igress on all ports to function
# # Fixes the following error:
# # At least one security group must open all igress ports.
# # To limit traffic, the source security group in your inbound rule can be
# # restricted to the same security group
resource "aws_security_group_rule" "glue_self_inbound" {
  count             = var.enabled
  description       = "Allow access to self"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.glue[0].id
  self              = true
}

resource "aws_security_group_rule" "outbound_all" {
  count             = var.enabled
  description       = "Allow all outbound access"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.glue[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}
