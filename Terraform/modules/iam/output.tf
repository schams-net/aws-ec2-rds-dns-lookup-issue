# Output variables

output "instance_profile" {
    value = aws_iam_instance_profile.ec2
}

output "roles" {
    value = {
        ec2 = aws_iam_role.ec2
    }
}