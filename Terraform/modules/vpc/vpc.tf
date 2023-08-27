# Virtual Private Cloud (VPC)

resource "aws_vpc" "default" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    assign_generated_ipv6_cidr_block = true
    tags = merge(var.tags, {
        Name = "${var.tags.name}"
    })
}