# VPC Route Tables

# route table for public subnets
resource "aws_route_table" "public" {
    count = var.subnet_count
    vpc_id = aws_vpc.default.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }
    route {
        ipv6_cidr_block = "::/0"
        egress_only_gateway_id = aws_egress_only_internet_gateway.default.id
    }
    tags = merge(var.tags, {
        Name = "[${var.tags.name}] public subnets"
    })
}

resource "aws_route_table_association" "public" {
    count = var.subnet_count
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public[count.index].id
}