# Main modules

# Amazon Virtual Private Cloud (Amazon VPC)
module "aws_vpc" {
    source = "./modules/vpc"
    tags = var.tags
}

# AWS Identity and Access Management (IAM)
module "aws_iam" {
    source = "./modules/iam"
    ec2_instances = module.aws_ec2.instances
    tags = var.tags
}

# Amazon Elastic Compute Cloud (EC2)
module "aws_ec2" {
    source = "./modules/ec2"
    vpc = module.aws_vpc.vpc
    subnets = module.aws_vpc.subnets.public
    instance_profile = module.aws_iam.instance_profile
    rds_aurora_cluster = module.aws_rds.cluster
    tags = var.tags
}

# Amazon RDS Aurora Serverless
module "aws_rds" {
    source = "./modules/rds-aurora"
    vpc = module.aws_vpc.vpc
    subnets = module.aws_vpc.subnets.public
    tags = var.tags
}