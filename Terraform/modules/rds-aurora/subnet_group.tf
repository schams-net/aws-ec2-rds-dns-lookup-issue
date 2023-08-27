# Amazon RDS Aurora Serverless (MySQL)

resource "aws_db_subnet_group" "default" {
    name = "${lower(var.tags.name)}"
    subnet_ids = var.subnets[*].id
}