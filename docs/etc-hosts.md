# Write the IP Addresses into /etc/hosts

## Summary

The actions described below address the issue but don't solve the root cause of the problem. By storing the IP Addresses hard-coded in the file `/etc/hosts`, the system bypasses the DNS look-up.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Store the IP address of the RDS Aurora cluster in the local `hosts` file:

```console
$ echo -e "\n${RDS_ENDPOINT_IP} ${RDS_DNS_NAME}" | sudo tee --append /etc/hosts
```

## Drawbacks

As the IP address of the RDS Aurora cluster can change at any time, storing the IP address hard-coded in the system configuration is not the final solution and can lead to system failures.
