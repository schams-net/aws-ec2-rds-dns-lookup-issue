# ...

locals {
    cloudconfig_debian = templatefile(
        "${path.module}/templates/cloudconfig/debian.tftpl",
        {
            billing_id = var.tags.billing-id
            rds_dns_name = var.rds_aurora_cluster.endpoint
        }
    )
    cloudconfig_amzn2 = templatefile(
        "${path.module}/templates/cloudconfig/amzn2.tftpl",
        {
            billing_id = var.tags.billing-id
            rds_dns_name = var.rds_aurora_cluster.endpoint
        }
    )
}