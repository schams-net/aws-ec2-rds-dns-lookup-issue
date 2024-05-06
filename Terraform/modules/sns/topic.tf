# Amazon Simple Notification Service (SNS)

resource "aws_sns_topic" "alarm_notifications" {
    name = "${lower(var.tags.name)}-alarm-notifications"
    tags = var.tags
}