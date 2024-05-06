# AWS EC2 RDS DNS Look-up Issue

> Important note: Be aware that the cloud images `debian-12-amd64-20240415-1718` and newer no longer enable `libnss-resolve` by default. This issue described in this document has been mitigated in EC2 instances launched from these and future images. See [issue 29069](https://github.com/systemd/systemd/issues/29069) (mainly the [comments](https://github.com/systemd/systemd/issues/29069#issuecomment-2057781457) on 16 April 2024 and later) of the `systemd` GitHub repository for further details.

## Problem Description

EC2 instances with Debian v12 show intermittent DNS name resolution failures when they perform a DNS look-up of the RDS Aurora endpoint. The instances use the Amazon-provided DNS server (`VPC.2`). While approx. 90 percent of the DNS queries succeed, 10 percent fail (*name or service not known*).

We experience this issue with the official [Debian v12 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/Bookworm) but don't experience the problem on [Debian v11 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye).

The issue is reproducible on different instance types and sizes, across various regions, and without any custom applications or packages installed (*empty* Debian v12 instance).

The details below outline how to reproduce the problem in a basic environment and which actions have been taken to analyse the issue and to rule out certain causes.

# Prerequisites

- [How to reproduce the issue](docs/how-to-reproduce-the-issue.md)
- [Terraform plan](docs/terraform-plan.md) to deploy an environment for reproducing the issue

## Analysis

The following actions have been taken to analyse the issue:

- Rule out [VPC DNS throttling](docs/vpc-dns-throttling.md)
- [Packet capture](docs/packet-capture.md)
- [Monitor DNS queries](docs/monitor-dns-queries.md)
- [IPv6 address resolution](docs/ipv6-address-resolution.md)

## Actions without Effect

The following actions **do not** solve the issue:

- [Disable ENA support](docs/disable-ena-support.md)

## Workarounds

The following actions prevent the look-up failures from happening (but do not solve the issue):

- Write the IP addresses into the file `/etc/hosts` (see [further details](docs/etc-hosts.md)).
- Stop and disable the `systemd-resolved` service (see [further details](docs/disable-systemd-resolved.md)).
- Remove `resolve` from the file `/etc/nsswitch.conf` (see [further details](docs/etc-nsswitch-conf.md)).

## Miscellaneous

- [Query name servers](docs/query-name-servers.md)
- Use a [different DNS server](docs/different-dns-server.md)
- [Disable Local DNS Cache](docs/disable-local-dns-cache.md)
