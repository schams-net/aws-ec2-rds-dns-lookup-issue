# VPC default Security Groups

resource "aws_default_security_group" "default_vpc" {
    vpc_id = aws_vpc.default.id
    tags = merge(var.tags, {
        Name = "[${var.tags.name}] VPC"
    })
}