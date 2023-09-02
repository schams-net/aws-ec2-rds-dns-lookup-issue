# Disable the systemd-resolved Service

## Summary

The actions described below address the issue but don't solve the root cause of the problem.

> The process outlined below does not solve the problem.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

### Option 1: Stop/Disable the Service

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

### Option 2: Remove `resolve` from `nsswitch.conf`

Open the file `/etc/nsswitch.conf` in your favorite text editor, for example `vi`:

```console
$ sudo vi /etc/nsswitch.conf
```

Locate and update the following line:

```text
hosts: files resolve [!UNAVAIL=return] dns
```

Remove `resolve [!UNAVAIL=return]`, so that the line reads:

```text
hosts: files dns
```

Save the file and close the text editor.
