# How to Reproduce the Issue

## Summary

Reproducing the issue is rather simple. This section describes the required components (test infrastructure), the circumstances when the issue occurs, and the actions that need to be execute to trigger the error.

## Test Infrastructure

The issue occurs on EC2 instances based on official [Debian v12 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/), for example `ami-06885bf4009501fc0` in the `us-east-1` region. Resolving the DNS name of an RDS Aurora cluster fails repeatably (approx. 10% error rate). The EC2 instance and the RDS Aurora cluster run in a VPC with public subnet(s), route table(s), internet gateway, etc.

The directory `Terraform/` of the [Git repository](https://github.com/schams-net/aws-ec2-rds-dns-lookup-issue) contains a Terraform plan that creates a basic environment including all components to reproduce the issue.

## Run the Queries (Test)

Login to the **Debian v12 instance** through SSH and make sure that [cloudinit](https://cloud-init.io/) has finished before you proceed:

```console
$ tail -f /var/log/cloud-init-output.log
```

Get familiar with the setup, for example:

```console
$ cat /etc/debian_version
```

```console
$ cat /etc/resolv.conf
```

```console
$ echo "${RDS_DNS_NAME}"
```

```console
$ mariadb -h ${RDS_DNS_NAME} -u dbadmin -ppassword -e "SHOW DATABASES"
```

The following commands generate 100 DNS queries and look up the IP address of the RDS Aurora cluster in an 1-second interval. They open a TCP connection to the DB cluster through `netcat` and immediately close the connection again.

```console
$ QUERIES=100 ; ERRORS=0 ; PROGRESS="" ; echo ; for COUNT in $(seq 1 ${QUERIES}); do nc -zv ${RDS_DNS_NAME} 3306 ; RETURN=$? ; if [ ${RETURN} -ne 0 ]; then let ERRORS=ERRORS+1 ; PROGRESS="${PROGRESS}X" ; else PROGRESS="${PROGRESS}." ; fi ; sleep 1 ; done ; echo -e "\n${PROGRESS}\n${ERRORS} errors out of ${QUERIES} queries\n"
```

This succeeds in most cases, shown by the following lines:

```text
Connection to <rds-aurora-endpoint> (<rds-aurora-ip>) 3306 port [tcp/mysql] succeeded!
```

In some cases (approx. 10 out of 100), the IP address can't be resolved. The line below shows the error output:

```text
nc: getaddrinfo for host "<rds-aurora-endpoint>" port 3306: Name or service not known
```

At the end of the tests, the commands output the result of the test, for example:

```text
..........X................X...................X....X....X....X...............XX........X....X......
10 errors out of 100 queries
```

A dot represents a successfull DNS look-up and connection, an `X` represents a failed look-up.
