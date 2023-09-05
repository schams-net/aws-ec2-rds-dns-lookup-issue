# Global output variables

output "s3_bucket" {
    value = "s3://${module.aws_s3.s3_bucket.bucket}"
}

output "debian_amis" {
    value = {
        debian11 = module.aws_ec2.amis.debian11.id
        debian12 = module.aws_ec2.amis.debian12.id
        amzn2 = module.aws_ec2.amis.amzn2.id
    }
}

output "public_ipv4" {
    value = {
        debian11 = module.aws_ec2.instances.debian11.public_ip
        debian12 = module.aws_ec2.instances.debian12.public_ip
        amzn2 = module.aws_ec2.instances.amzn2.public_ip
    }
}