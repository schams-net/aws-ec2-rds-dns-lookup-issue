# ...

resource "aws_route53_resolver_query_log_config" "query_logs" {
    name = "${lower(var.tags.name)}"
    destination_arn = var.s3_bucket.arn
    tags = var.tags
}

resource "aws_route53_resolver_query_log_config_association" "query_logs" {
    resolver_query_log_config_id = aws_route53_resolver_query_log_config.query_logs.id
    resource_id = var.vpc.id
}