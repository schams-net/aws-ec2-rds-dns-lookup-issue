# ...

resource "aws_cloudwatch_metric_alarm" "ec2_status_checks_debian12" {
    alarm_name = "${lower(var.tags.name)}-ec2-status-check-debian12"
    alarm_description = "Status checks of EC2 instance ${var.ec2_instances.debian12.id}"
    metric_name = "StatusCheckFailed"
    namespace = "AWS/EC2"

    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 5
    threshold = 1
    period = 60
    datapoints_to_alarm = 5
    statistic = "Average"

	# Sets how this alarm is to handle missing data points.
	# Valid values: missing (default), ignore, breaching and notBreaching.
    treat_missing_data = "missing"

    dimensions = {
        InstanceId = var.ec2_instances.debian12.id
    }

    actions_enabled = "true"
    alarm_actions = [
        var.sns_topics.alarm_notifications.arn,
        #"arn:aws:automate:${data.aws_region.current.name}:ec2:reboot",
        "arn:aws:swf:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"
    ]
    ok_actions = [
        var.sns_topics.alarm_notifications.arn
    ]

    tags = var.tags
}