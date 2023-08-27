# Output variables

output "amis" {
    value = {
        debian11 = data.aws_ami.debian11
        debian12 = data.aws_ami.debian12
    }
}

output "instances" {
    value = {
        debian11 = aws_instance.debian11
        debian12 = aws_instance.debian12
    }
}