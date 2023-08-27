# Global variables

variable "profile" {
    type = string
    default = "default"
}

variable "region" {
    type = string
    default = "us-east-1"
}

variable "tags" {
    type = map
    default = {
        "name"  = "RdsDnsLookup"
        "billing-id" = "aws-test"
        "environment" = "lookup"
    }
}