# SSH key pair

locals {
    timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

resource "tls_private_key" "private_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
    key_name = "${var.tags.name}-${local.timestamp}"
    public_key = tls_private_key.private_key.public_key_openssh

    lifecycle {
        ignore_changes = [ key_name ]
    }

    # write private key to local file system
    provisioner "local-exec" {
        command = "echo '${tls_private_key.private_key.private_key_pem}' > /tmp/private.pem ; chmod 600 /tmp/private.pem"
    }
}