# VPC subnets

resource "aws_subnet" "public" {
    count = var.subnet_count
    vpc_id = aws_vpc.default.id
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 10)
    ipv6_cidr_block = cidrsubnet(aws_vpc.default.ipv6_cidr_block, 8, count.index)
    assign_ipv6_address_on_creation = false
    map_public_ip_on_launch = true
    tags = merge(var.tags, {
        Name = "[${var.tags.name}] public zone ${data.aws_availability_zones.available.names[count.index]}"
    })
}