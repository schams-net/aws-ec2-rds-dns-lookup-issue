# Output variables

output "topics" {
    value = {
        alarm_notifications = aws_sns_topic.alarm_notifications
    }
}