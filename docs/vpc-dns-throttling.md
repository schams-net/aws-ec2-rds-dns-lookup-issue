# VPC DNS Throttling

## Summary

Amazon-provided DNS servers enforce a limit of 1024 packets per second per elastic network interface (ENI) and reject any traffic exceeding this limit. See the [AWS Knowledge Center](https://repost.aws/knowledge-center/vpc-find-cause-of-failed-dns-queries) for further details.

> The process outlined below proves that VPC DNS throttling **does not** cause the issue.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

The following command ([tcpdump](https://www.tcpdump.org)) captures the initial 350 bytes of the packet and saves 20 files of 100 MB each while overwriting the old packet captures:

```console
$ sudo tcpdump -i ens5 -s 350 -C 100 -W 20 -w /var/tmp/$(ec2metadata --instance-id).pcap
```

Please note that capturing packets takes some time on an (almost) unused EC2 instance (which also underlines that VPC DNS throttling can't be the root cause of the issue).

Run the following Linux command to determine the number of DNS queries sent:

```console
$ tcpdump -r /var/tmp/$(ec2metadata --instance-id).pcap* -nn dst port 53 | awk -F " " '{ print $1 }' | cut -d"." -f1 | uniq -c
```

Follow the instructions in option 3 (ENA driver network performance metric). Use the following command to determine the version of the Elastic Network Adapter (ENA) driver:

```console
$ sudo ethtool -i ens5 | grep version
```

Execute the following command to output metrics with the keyword `allowance`:

```console
$ sudo ethtool -S ens5 | grep allowance
```

The metric `linklocal_allowance_exceeded` is `0`.
