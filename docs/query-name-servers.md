# Query Name Servers

## Summary

The issue as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md) occurs with commands such as `netcat` and `mariadb` (client). We haven't be able to produce the error with `dig` as the details below show (error rate with `dig` is 0%).

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for exampled provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Execute the following command to store the RDS IP address as the environment variable `RDS_ENDPOINT_IP`:

```console
$ RDS_ENDPOINT_IP=$(host ${RDS_DNS_NAME} | grep "has address" | sed 's/.*has address \(.*\)$/\1/g') ; echo "RDS IP: ${RDS_ENDPOINT_IP}"
```

Run the following commands to execute 100 queries against AWS' internal DNS to look up the IP address of the RDS Aurora cluster:

```console
QUERIES=100 ; ERRORS=0 ; echo ; for COUNT in $(seq 1 ${QUERIES}); do IP_ADDRESS=$(dig +short @192.168.0.2 ${RDS_DNS_NAME} | tail -1) ; RETURN=$? ; if [ ! "${IP_ADDRESS}" = "${RDS_ENDPOINT_IP}" ]; then let ERRORS=ERRORS+1 ; echo -n "X" ; else echo -n "." ; fi ; sleep 1 ; done ; echo -e "\n${ERRORS} errors out of ${QUERIES} queries\n"
```

The following commands execute 100 queries against Google's DNS (`8.8.8.8`) to look up the IP of the RDS Aurora cluster:

```console
QUERIES=100 ; ERRORS=0 ; echo ; for COUNT in $(seq 1 ${QUERIES}); do IP_ADDRESS=$(dig +short @8.8.8.8 ${RDS_DNS_NAME} | tail -1) ; RETURN=$? ; if [ ! "${IP_ADDRESS}" = "${RDS_ENDPOINT_IP}" ]; then let ERRORS=ERRORS+1 ; echo -n "X" ; else echo -n "." ; fi ; sleep 1 ; done ; echo -e "\n${ERRORS} errors out of ${QUERIES} queries\n"
```
