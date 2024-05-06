# IAM Role

resource "aws_iam_role" "ec2" {
    name = "${var.tags.environment}-ec2"
    assume_role_policy = file("${path.module}/json/assume_role_ec2.json")
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_admin_policy" {
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
    role = aws_iam_role.ec2.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    role = aws_iam_role.ec2.name
}

# Inline policy
# Allowing the CloudWatch agent to set log retention policy
resource "aws_iam_role_policy" "set_log_retention_policy" {
    name = "set-log-retention-policy"
    role = aws_iam_role.ec2.id
    policy = file("${path.module}/json/set_log_retention_policy.json")
}