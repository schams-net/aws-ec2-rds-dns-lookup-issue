# Amazon RDS Aurora Serverless (MySQL)

resource "aws_db_subnet_group" "default" {
    name = "${lower(var.tags.name)}"
    description = "RDS DB subnet group"
    subnet_ids = var.subnets[*].id
    tags = var.tags
}