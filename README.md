# AWS EC2 RDS DNS Look-up Issue

## Problem Description

EC2 instances with Debian v12 show intermittent DNS name resolution failures when they perform a DNS look-up of the RDS Aurora endpoint. The instances use the Amazon-provided DNS server (`VPC.2`). While approx. 90 percent of the DNS queries succeed, 10 percent fail (*name or service not known*).

We experience this issue with the official [Debian v12 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/Bookworm) but don't experience the problem on [Debian v11 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye).

The issue is reproducible on different instance types and sizes, across various regions, and without any custom applications or packages installed (*empty* Debian v12 instance).

The details below outline how to reproduce the problem in a basic environment and which actions have been taken to analyse the issue and to rule out certain causes.

# Prerequisites

- [How to reproduce the issue](how-to-reproduce-the-issue.md)
- [Terraform plan](terraform-plan.md) to deploy an environment for reproducing the issue

## Analysis

The following actions have been taken to analyse the issue:

- Rule out [VPC DNS throttling](vpc-dns-throttling.md)
- [Package capture](package-capture.md)
- [Monitor DNS queries](monitor-dns-queries.md)
- [IPv6 address resolution](ipv6-address-resolution.md)

## Actions without Effect

The following actions **do not** solve the issue:

- [Disable ENA support](disable-ena-support.md)

## Workarounds

The following actions address prevent the look-up failures from happening (but do not solve the issue):

- Write the IP addresses into the file `/etc/hosts` (see [further details](etc-hosts.md)).
- Stop and disable the `systemd-resolved` service (see [further details](disable-systemd-resolved.md)).

## Miscellaneous

- [Query name servers](query-name-servers.md)
- Use a [different DNS server](different-dns-server.md)
- [Disable Local DNS Cache](disable-local-dns-cache.md)
