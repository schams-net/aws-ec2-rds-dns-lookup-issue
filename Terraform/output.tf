# Global output variables

output "debian_amis" {
    value = {
        debian11 = module.aws_ec2.amis.debian11.id
        debian12 = module.aws_ec2.amis.debian12.id
    }
}

output "public_ipv4" {
    value = {
        debian11 = module.aws_ec2.instances.debian11.public_ip
        debian12 = module.aws_ec2.instances.debian12.public_ip
    }
}