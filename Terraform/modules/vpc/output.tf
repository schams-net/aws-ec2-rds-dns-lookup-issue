# Output variables

output "vpc" {
    value = aws_vpc.default
}

output "subnets" {
    value = {
        public = aws_subnet.public
    }
}