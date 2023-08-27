# IAM Role

resource "aws_iam_role" "ec2" {
    name = "${var.tags.environment}-ec2"
    assume_role_policy = file("${path.module}/json/assume_role_ec2.json")
    tags = var.tags
}