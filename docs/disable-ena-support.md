# Disable ENA Support

## Summary

Amazon EC2 provides enhanced networking capabilities through the Elastic Network Adapter (ENA). To rule out that the ENA support causes the issue, follow the instructions below.

> The process outlined below proves that ENA support **does not** cause the issue.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Verify that the `ena` module is installed by using the `modinfo` command as shown in the following example.

```console
$ sudo modinfo ena
```

Use the following command to verify that the `ena` module is being used on the `ens5` interface:

```console
$ sudo ethtool -i ens5
```

Use the AWS Management Console (or appropriate API calls) to stop the instance. Change the instance type to `t2.micro` and disable ENA support, for example by executing the following command on your local machine:

```console
$ aws --region <region> ec2 modify-instance-attribute --instance-id <instance-id> --no-ena-support
```

Restart the instance and run the tests again (see section [How to Reproduce the Issue](how-to-reproduce-the-issue.md)).
