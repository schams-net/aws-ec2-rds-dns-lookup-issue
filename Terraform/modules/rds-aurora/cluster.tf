# Amazon RDS Aurora Serverless (MySQL)

resource "aws_rds_cluster" "default" {
    cluster_identifier = "${lower(var.tags.name)}-aurora-cluster"

    # MySQL
    engine = "aurora-mysql"
    engine_version = "8.0.mysql_aurora.3.03.0"
    engine_mode = "provisioned"

    availability_zones = var.subnets[*].availability_zone
    network_type = "DUAL"

    lifecycle {
        ignore_changes = [ availability_zones ]
    }

    master_username = "dbadmin"
    master_password = "password"
    #manage_master_user_password = true

    iam_database_authentication_enabled = true

    # Name for an automatically created database on cluster creation
    database_name = replace(lower(var.tags.name), "/[^a-z0-9]/", "")

    # If true, a final DB snapshot is created before the DB cluster is deleted.
    skip_final_snapshot = true

    serverlessv2_scaling_configuration {
        # The minimum capacity for an Aurora DB cluster in provisioned DB engine mode.
        # The minimum capacity must be lesser than or equal to the maximum capacity.
        # Valid capacity values are in a range of 0.5 up to 128 in steps of 0.5.
        min_capacity = 0.5

        # The maximum capacity for an Aurora DB cluster.
        # Valid capacity values: same as above.
        max_capacity = 1.0
    }

    backup_retention_period = 1
    preferred_backup_window = "12:00-14:59"
    preferred_maintenance_window = "tue:15:00-tue:16:59"

    apply_immediately = true

    copy_tags_to_snapshot = true

    storage_encrypted = true

    db_subnet_group_name = aws_db_subnet_group.default.name
    vpc_security_group_ids = [ aws_security_group.rds.id ]
    #db_cluster_parameter_group_name = var.parameter_group.name

    tags = var.tags
}