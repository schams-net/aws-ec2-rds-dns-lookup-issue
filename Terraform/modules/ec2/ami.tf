# Debian GNU/Linux AMI

data "aws_ami" "debian11" {
    most_recent = true
    filter {
        name = "name"
        values = ["debian-11-amd64-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    # owner: Debian
    owners = ["136693071363"]
}

data "aws_ami" "debian12" {
    most_recent = true
    filter {
        name = "name"
        values = ["debian-12-amd64-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    # owner: Debian
    owners = ["136693071363"]
}

data "aws_ami" "amzn2" {
    most_recent = true
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    # owner: Amazon
    owners = ["137112412989"]
}