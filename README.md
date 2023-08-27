# AWS EC2 RDS DNS Lookup Issue

## How to Reproduce the Issue

### Infrastructure Deployment

On your local machine:

```console
$ git clone https://github.com/schams-net/aws-ec2-rds-dns-lookup-issue.git
$ cd aws-ec2-rds-dns-lookup-issue/Terraform
$ terraform init
```

Review and edit the file `variables.tf` to adjust global settings such as AWS account (default: `default`) and the region.

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

Login to the Debian v12 instance through SSH.

Make sure that [cloudinit](https://cloud-init.io/) has finished before you proceed:

```console
$ tail -f /var/log/cloud-init-output.log
```

Get familiar with the setup:

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

The following commands generate 100 DNS queries and look up the IP address of the RDS Aurora cluster in an 1-second interval. They open a TCP connection to the DB cluster through netcat and close the connection straight after:

```console
$ QUERIES=100 ; ERRORS=0 ; PROGRESS="" ; echo ; for COUNT in $(seq 1 ${QUERIES}); do nc -zv ${RDS_DNS_NAME} 3306 ; RETURN=$? ; if [ ${RETURN} -ne 0 ]; then let ERRORS=ERRORS+1 ; PROGRESS="${PROGRESS}X" ; else PROGRESS="${PROGRESS}." ; fi ; sleep 1 ; done ; echo -e "\n${PROGRESS}\n${ERRORS} errors out of ${QUERIES} queries\n"
```

This succeeds in most cases.

```text
Connection to <rds-aurora-endpoint> (192.168.10.25) 3306 port [tcp/mysql] succeeded!
```

In some cases (approx. 10 out of 100), the IP address can't be resolved.

```text
nc: getaddrinfo for host "<rds-aurora-endpoint>" port 3306: Name or service not known
```
```

At the end of the tests, the commands output the result of the test run, for example:

```text
..........X................X...................X....X....X....X...............XX........X....X......
10 errors out of 100 queries
```

A dot represents a successfull DNS look-up and connection, an `X` represents a failed look-up.

## Check VPC DNS Throttling

Amazon-provided DNS servers enforce a limit of 1024 packets per second per elastic network interface. Amazon provided DNS servers reject any traffic exceeding this limit. See the [AWS Knowledge Center](https://repost.aws/knowledge-center/vpc-find-cause-of-failed-dns-queries) for further details.

Follow the instructions in option 1 (use tcpdump) to prove that VPC DNS throttling is not the cause of the issue.

```console
$ sudo tcpdump -i ens5 -s 350 -C 100 -W 20 -w /var/tmp/$(curl -s http://169.254.169.254/latest/meta-data/instance-id).$(date +%Y-%m-%d:%H:%M:%S).pcap
```

```console
$ tcpdump  -r <file_name.pcap> -nn dst port 53 | awk -F " " '{ print $1 }' | cut -d"." -f1 | uniq -c
```

Follow the instructions in option 3 (ENA driver network performance metric):

Elastic Network Adapter (ENA)

```console
$ sudo ethtool -i ens5 | grep version
$ sudo ethtool -S ens5 | grep allowance
```

The metric `linklocal_allowance_exceeded` is `0`.

## DNS Query Logging and Packet Capture

This section documents how to enable DNS query logging and capture the network traffic for further analysis.

Make sure, required tools are installed on the instance.

```console
$ sudo apt-get install --yes bind9 bind9utils bind9-dnsutils bind9-doc bind9-host
```

Switch to user "root" (and execute subsequent commands as user "root"):

```console
$ sudo su
```

Enable DNS query logging:

```console
$ rndc querylog
```

Start packet capture:

```console
$ tcpdump -ni any -w $(ec2metadata --instance-id).pcapng &
```

Press `ENTER` twice to return to the command prompt and run the tests again (see above).

Stop the packet capture:

```console
$ fg
```

Press `CTRL`+`c` to stop the packet capture.

```console
$ journalctl | gzip -c > $(ec2metadata --instance-id).log.gz
```

Switch back to user "admin":

```console
$ exit
```

## Disable ENA Support

I also tested if the ENA support could cause the problem as summarized in this section.

Change the instance type to `t2.micro` and disable ENA support.

```console
$ aws --region ap-southeast-2 ec2 modify-instance-attribute --instance-id <instance-id> --no-ena-support
```

## Query Name Servers With `dig`

The issue occurs with commands such as `netcat` and `mariadb` (client) but I haven't be able to produce the error with `dig`. This section documents how I ran the tests. The error rate with `dig` is 0%.

```console
$ RDS_ENDPOINT_IP=$(host ${RDS_DNS_NAME} | grep "has address" | sed 's/.*has address \(.*\)$/\1/g') ; echo "RDS IP: ${RDS_ENDPOINT_IP}"
```

The following commands execute 100 queries against AWS' internal DNS to look up the IP of the RDS Aurora cluster.

```console
QUERIES=100 ; ERRORS=0 ; echo ; for COUNT in $(seq 1 ${QUERIES}); do IP_ADDRESS=$(dig +short @192.168.0.2 ${RDS_DNS_NAME} | tail -1) ; RETURN=$? ; if [ ! "${IP_ADDRESS}" = "${RDS_ENDPOINT_IP}" ]; then let ERRORS=ERRORS+1 ; echo -n "X" ; else echo -n "." ; fi ; sleep 1 ; done ; echo -e "\n${ERRORS} errors out of ${QUERIES} queries\n"
```

The following commands execute 100 queries against Google's DNS (`8.8.8.8`) to look up the IP of the RDS Aurora cluster.

```console
QUERIES=100 ; ERRORS=0 ; echo ; for COUNT in $(seq 1 ${QUERIES}); do IP_ADDRESS=$(dig +short @8.8.8.8 ${RDS_DNS_NAME} | tail -1) ; RETURN=$? ; if [ ! "${IP_ADDRESS}" = "${RDS_ENDPOINT_IP}" ]; then let ERRORS=ERRORS+1 ; echo -n "X" ; else echo -n "." ; fi ; sleep 1 ; done ; echo -e "\n${ERRORS} errors out of ${QUERIES} queries\n"
```

## Disabling Local DNS Cache

I tested if a disabled local DNS cache makes any differences as documented in this section.

```console
$ sudo mkdir /etc/systemd/resolved.conf.d/
$ echo -e "[Resolve]\nCache=no" | sudo tee /etc/systemd/resolved.conf.d/dns.conf
```

```console
$ sudo systemctl restart systemd-resolved
```

Re-running the tests (see section "Run the Queries (Test)" above) shows that the errors still occur.
