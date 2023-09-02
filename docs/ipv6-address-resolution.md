# IPv6 Address Resolution

## Summary

The tests and the [packet capture](packet-capture.md) indicate that the error is related to IPv6 address resolution. This section documents an observation related to *external* DNS names (not the RDS Aurora cluster endpoint) which results in an 100% success rate.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Change the commands to execute 100 queries to look up the IP address of the RDS Aurora cluster to use a domain name such as `debian.org` or `schams.net`. Both names have valid IPv6 addresses.

```console
# previously use command:
nc -zv ${RDS_DNS_NAME} 3306
```

```console
# query debian.org instead:
nc -zv debian.org 80
```

The resulting commands to re-test the issue are:

```console
$ QUERIES=100 ; ERRORS=0 ; PROGRESS="" ; echo ; for COUNT in $(seq 1 ${QUERIES}); do nc -zv debian.org 80 ; RETURN=$? ; if [ ${RETURN} -ne 0 ]; then let ERRORS=ERRORS+1 ; PROGRESS="${PROGRESS}X" ; else PROGRESS="${PROGRESS}." ; fi ; sleep 1 ; done ; echo -e "\n${PROGRESS}\n${ERRORS} errors out of ${QUERIES} queries\n"
```

As this change results in a 100% success rate, we suspect that the error is not isolated from the VPC or `VPC.2` name servers.
