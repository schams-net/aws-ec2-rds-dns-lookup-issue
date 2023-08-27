# Amazon RDS Aurora Serverless (MySQL)

resource "aws_rds_cluster_instance" "default" {

    # count = var.subnet_count
    count = 1

    identifier = "aurora-serverless-${data.aws_availability_zones.available.names[count.index]}"
    cluster_identifier = aws_rds_cluster.default.id
    instance_class = "db.serverless"
    engine = aws_rds_cluster.default.engine
    engine_version = aws_rds_cluster.default.engine_version
    #ca_cert_identifier = "rds-ca-2019"
    ca_cert_identifier = "rds-ca-rsa2048-g1"

    publicly_accessible = false
    apply_immediately = true
    availability_zone = data.aws_availability_zones.available.names[count.index]
    db_subnet_group_name = aws_db_subnet_group.default.name
    copy_tags_to_snapshot = true

    tags = merge(var.tags, {
        Name = "${var.tags.name} ${data.aws_availability_zones.available.names[count.index]}"
    })
}