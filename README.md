# AWS EC2 RDS DNS Look-up Issue

## Problem Description

EC2 instances with Debian v12 show intermittent DNS name resolution failures when they perform a DNS look-up of the RDS Aurora endpoint. The instances use the Amazon-provided DNS server (`VPC.2`). While approx. 90 percent of the DNS queries succeed, 10 percent fail (*name or service not known*).

We experience this issue with the official [Debian v12 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/Bookworm) but don't experience the problem on [Debian v11 AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye).

The issue is reproducible on different instance types and sizes (the demo below uses the `t3`-family), across various regions, and without any custom applications or packages installed (*empty* Debian v12 instance).

The information below outlines how to reproduce the problem in a basic environment, and which actions have been taken to analyse the issue and rule out certain causes.

## How to Reproduce the Issue

### Test Infrastructure

The [Git repository](https://github.com/schams-net/aws-ec2-rds-dns-lookup-issue) at GitHub contains a Terraform plan that creates a basic environment containing the following components:

- VPC with 2x public subnets, route tables, 1x internet gateway, etc.
- 1x RDS Aurora Serverless v2 cluster with 1x DB instance (MySQL).
- 2x EC2 instances (1x Debian v11, 1x Debian v12) based on [Debian's official AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/).

### Infrastructure Deployment

On your local machine:

```console
$ git clone https://github.com/schams-net/aws-ec2-rds-dns-lookup-issue.git
$ cd aws-ec2-rds-dns-lookup-issue/Terraform
$ terraform init
```

Review the file `variables.tf` and adjust the settings as required. For example the AWS profile name (default: `default`) and the region. Once done, roll out the stack by executing the following command:

```console
$ terraform apply
```

The deployment takes approx. 20 minutes to complete. Once the process finished, Terraform outputs Debian's AMIs used for the EC2 instance and the instancess public IPv4 addresses, for example:

```console
debian_amis = {
  "debian11" = "ami-xxxxxxxxxxxxxxxxx"
  "debian12" = "ami-yyyyyyyyyyyyyyyyy"
}
public_ipv4 = {
  "debian11" = "xxx.xxx.xxx.xxx"
  "debian12" = "yyy.yyy.yyy.yyy"
}
```

Terraform writes the **private** SSH key to `/tmp/private.pem`. Update the file permissions and use this key to login to the instance through SSH (see next section).

### Run the Queries (Test)

Login to the **Debian v12 instance** through SSH.

Make sure that [cloudinit](https://cloud-init.io/) has finished before you proceed:

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

## Check VPC DNS Throttling

Amazon-provided DNS servers enforce a limit of 1024 packets per second per elastic network interface (ENI) and reject any traffic exceeding this limit. See the [AWS Knowledge Center](https://repost.aws/knowledge-center/vpc-find-cause-of-failed-dns-queries) for further details.

Follow the instructions in option 1 (use [tcpdump](https://www.tcpdump.org)) to prove that VPC DNS throttling **does not** cause of the issue. The following command captures the initial 350 bytes of the packet and saves 20 files of 100 MB each while overwriting the old packet captures:

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

## DNS Query Logging and Packet Capture

This section documents how to enable DNS query logging and capture the network traffic for further analysis.

The following command enables DNS query logging:

```console
$ sudo rndc querylog
```

Start packet capture by executing the following `tcpdump` command (in the background):

```console
$ sudo tcpdump -ni any -w $(ec2metadata --instance-id).pcap &
```

Press `ENTER` twice to return to the command prompt and run the tests again (see above). Bring the `tcpdump` process to the foreground:

```console
$ fg
```

Press `CTRL`+`c` to stop the packet capture. The file `<instance-id>.pcap` in the current directory contains the captured packets.

Run the following command to export the system messages (previously known as `/var/log/syslog`) into a new file file `<instance-id>.log.gz`:

```console
$ sudo journalctl | gzip -c > $(ec2metadata --instance-id).log.gz
```

## ENA Support

Amazon EC2 provides enhanced networking capabilities through the Elastic Network Adapter (ENA). To rule out that the ENA support causes the issue, follow the instructions below.

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

Restart the instance and run the tests again (see section above).

## Query Name Servers With `dig`

The issue occurs with commands such as `netcat` and `mariadb` (client). We haven't be able to produce the error with `dig` as the details below show (error rate with `dig` is 0%).

Execute the following command store the RDS IP address as the environment variable `RDS_ENDPOINT_IP`:

```console
$ RDS_ENDPOINT_IP=$(host ${RDS_DNS_NAME} | grep "has address" | sed 's/.*has address \(.*\)$/\1/g') ; echo "RDS IP: ${RDS_ENDPOINT_IP}"
```

The following commands execute 100 queries against AWS' internal DNS to look up the IP address of the RDS Aurora cluster:

```console
QUERIES=100 ; ERRORS=0 ; echo ; for COUNT in $(seq 1 ${QUERIES}); do IP_ADDRESS=$(dig +short @192.168.0.2 ${RDS_DNS_NAME} | tail -1) ; RETURN=$? ; if [ ! "${IP_ADDRESS}" = "${RDS_ENDPOINT_IP}" ]; then let ERRORS=ERRORS+1 ; echo -n "X" ; else echo -n "." ; fi ; sleep 1 ; done ; echo -e "\n${ERRORS} errors out of ${QUERIES} queries\n"
```

The following commands execute 100 queries against Google's DNS (`8.8.8.8`) to look up the IP of the RDS Aurora cluster:

```console
QUERIES=100 ; ERRORS=0 ; echo ; for COUNT in $(seq 1 ${QUERIES}); do IP_ADDRESS=$(dig +short @8.8.8.8 ${RDS_DNS_NAME} | tail -1) ; RETURN=$? ; if [ ! "${IP_ADDRESS}" = "${RDS_ENDPOINT_IP}" ]; then let ERRORS=ERRORS+1 ; echo -n "X" ; else echo -n "." ; fi ; sleep 1 ; done ; echo -e "\n${ERRORS} errors out of ${QUERIES} queries\n"
```

## Use a Different DNS Server

> Note: It is not certain whether the following changes take effect (see output of the command `resolvectl status`).

Replace the symbolic `/etc/resolv.conf` with a file that changes the DNS servers to Google's DNS:

```console
$ sudo rm /etc/resolv.conf
$ echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4\nsearch .\n" | sudo tee /etc/resolv.conf
```

Restart the systemd services:

```console
$ sudo systemctl daemon-reload
$ sudo systemctl restart systemd-networkd
$ sudo systemctl restart systemd-resolved
```

Verify the updated configuration by executing the following command:

```console
$ systemd-analyze cat-config systemd/resolved.conf
```

Re-running the tests shows that this approach **does not** fix the problem. Therefore, restore the system to the original setup:

```console
$ sudo rm /etc/resolv.conf
$ sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

Restart the systemd services as outlined above.

## Disable Local DNS Cache

> Note: It is not certain whether the following changes take effect (see output of the command `resolvectl status`).

Disabling the local DNS cache does not make any differences either as the following commands prove.

```console
$ sudo mkdir /etc/systemd/resolved.conf.d/
$ echo -e "[Resolve]\nCache=no" | sudo tee /etc/systemd/resolved.conf.d/dns.conf
```

Restart the systemd services as outlined in the previous section.

## Bypass DNS Look-up

The actions described in this section address the issue but don't solve the root cause of the problem. As the IP address of the RDS Aurora cluster can change at any time, storing the IP address hard-coded in the system is not a solution and can lead to system failures.

Store the IP address of the RDS Aurora cluster in the local `hosts` file:

```console
$ echo -e "\n${RDS_ENDPOINT_IP} ${RDS_DNS_NAME}" | sudo tee --append /etc/hosts
```
