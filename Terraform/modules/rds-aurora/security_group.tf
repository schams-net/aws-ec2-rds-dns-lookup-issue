# Security Group

resource "aws_security_group" "rds" {
    #name = "${lower(var.tags.name)}-rds-aurora"
    name = "${var.tags.name}-AuroraCluster"
    description = "[${var.tags.name}] RDS Aurora cluster"
    vpc_id = var.vpc.id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = var.subnets[*].cidr_block
        ipv6_cidr_blocks = var.subnets[*].ipv6_cidr_block
    }

    tags = merge(var.tags, {
        Name = "[${var.tags.name}] RDS Aurora cluster"
    })
}