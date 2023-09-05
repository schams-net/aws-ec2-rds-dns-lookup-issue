# ...

resource "aws_s3_bucket" "query_logs" {
    bucket = "${lower(var.tags.name)}.${var.random_identifier.hex}"

    # force_destroy: Indicates that all objects (including any locked objects)
    # should be deleted from the bucket when the bucket is destroyed. Otherwise
    # a "terraform destroy" can fail (if the bucket still contains objects).
    force_destroy = true

    tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "query_logs" {
    bucket = aws_s3_bucket.query_logs.bucket
    rule {
        bucket_key_enabled = true
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}
