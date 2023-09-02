# Disable Local DNS Cache

## Summary

The local DNS cache temporarily stores DNS data on the Debian v12 instance. The details below show that it does not make any differences if the local DNS cache is disabled.

> The process outlined below proves that the local DNS cache **does not** cause the issue.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Execute the following commands to disable the local DNS cache:

```console
$ sudo mkdir /etc/systemd/resolved.conf.d/
$ echo -e "[Resolve]\nCache=no" | sudo tee /etc/systemd/resolved.conf.d/dns.conf
```

Restart the systemd services:

```console
$ sudo systemctl daemon-reload
$ sudo systemctl restart systemd-networkd
$ sudo systemctl restart systemd-resolved
```

## Restore the System

Restore the system to the original setup:

```console
$ sudo rm /etc/systemd/resolved.conf.d/dns.conf
```

Restart the systemd services as outlined above.
