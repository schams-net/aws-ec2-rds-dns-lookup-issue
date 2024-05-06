# Disable the systemd-resolved Service

## Summary

The action described below addresses the issue but doesn't solve the root cause of the problem.

> The process outlined below does not solve the problem.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Remove `resolve` from `nsswitch.conf`

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
