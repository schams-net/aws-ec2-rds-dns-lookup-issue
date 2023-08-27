# Input variables

variable "cidr_block" {
    description = "Base CIDR block for the VPC"
    type = string
    default = "192.168.0.0/16"
}

variable "subnet_count" {
    description = "Number of subnets to be created inside the VPC"
    type = number
    default = 2
}

variable "tags" {
    type = map
}