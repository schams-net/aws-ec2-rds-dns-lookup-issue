# EC2 Instances

resource "aws_instance" "amzn2" {
    ami = data.aws_ami.amzn2.id
    instance_type = "t2.micro"
    iam_instance_profile = var.instance_profile.name
    vpc_security_group_ids = [ aws_security_group.ec2.id ]
    subnet_id = var.subnets[0].id
    associate_public_ip_address = true
    #private_ip = <disabled argument to auto-select private IPv4>
    ipv6_address_count = 1

    key_name = aws_key_pair.default.id
    user_data = local.cloudconfig_amzn2
    instance_initiated_shutdown_behavior = "stop"
    #instance_initiated_shutdown_behavior = "terminate"

    root_block_device {
        volume_type = "gp2"
        volume_size = "16"
        encrypted = true
        delete_on_termination = true
        tags = merge(var.tags, {
            Name = "[${var.tags.name}] Amazon Linux 2"
        })
    }

    lifecycle {
        ignore_changes = [ associate_public_ip_address ]
    }

    tags = merge(var.tags, {
        Name = "[${var.tags.name}] Amazon Linux 2"
    })
}

resource "aws_ec2_tag" "network_interface_amzn2_name" {
    resource_id = aws_instance.amzn2.primary_network_interface_id
    key = "Name"
    value = "[${var.tags.name}] Amazon Linux 2"
}

resource "aws_ec2_tag" "network_interface_amzn2_billing_id" {
    resource_id = aws_instance.amzn2.primary_network_interface_id
    key = "billing-id"
    value = var.tags.billing-id
}