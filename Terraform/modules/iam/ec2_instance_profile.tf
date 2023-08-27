# IAM EC2 Instance Profile

resource "aws_iam_instance_profile" "ec2" {
    name = "${var.tags.name}-ec2"
    role = aws_iam_role.ec2.id
}