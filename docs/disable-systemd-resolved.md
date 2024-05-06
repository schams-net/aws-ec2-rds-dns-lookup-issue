# Disable the systemd-resolved Service

## Summary

The action described below addresses the issue but doesn't solve the root cause of the problem.

> The process outlined below does not solve the problem.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Stop/Disable the Service

Execute the following command to stop the `systemd-resolved` service:

```console
$ sudo systemctl stop systemd-resolved
```

Optionally: execute the tests as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md) to verify that the stopped service addresses the issue.

As the system falls back to `dns`, resolving DNS names continues to work but does not use the `systemd-resolved` service (see option 2 below).

Execute the following command to remove (disable) the service from the system startup and make the change permanent even after a system reboot/restart:

```console
$ sudo systemctl disable systemd-resolved
```

Note: you can stop and disable the service with a single command:

```console
$ sudo systemctl disable --now systemd-resolved
```
