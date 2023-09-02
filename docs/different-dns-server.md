# Different DNS Server

## Summary

*@TODO: add summary paragraph.*

> The process outlined below proves that using different DNS servers **does not** solve the issue.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Execute the following commands to replace the symbolic `/etc/resolv.conf` with a file that changes the DNS servers to Google's DNS:

```console
$ sudo rm /etc/resolv.conf
$ echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4\nsearch .\n" | sudo tee /etc/resolv.conf
```

Restart the systemd services:

```console
$ sudo systemctl daemon-reload
$ sudo systemctl restart systemd-networkd
$ sudo systemctl restart systemd-resolved
```

Verify the updated configuration by executing the following command:

```console
$ systemd-analyze cat-config systemd/resolved.conf
```

Re-run the tests to prove that this approach **does not** fix the problem.

## Restore the System

Restore the system to the original setup:

```console
$ sudo rm /etc/resolv.conf
$ sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

Restart the systemd services as outlined above.
