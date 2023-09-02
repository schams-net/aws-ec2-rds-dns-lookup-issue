# Monitor DNS Queries

## Summary

Previous tests point to the nss stack of Debian v12 (where `systemd-resolved` is involved by way of `libnss_resolve.so`). The approach outlined below monitors the DNS queries and writes the details into a file for further analysis.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

Execute the following command to monitor the DNS queries and writes the communication between the EC2 instance and the AWS' DNS into a file:

```console
$ sudo resolvectl monitor > /tmp/resolvectl.monitor.log &
```

Run the tests again (see section [How to Reproduce the Issue](how-to-reproduce-the-issue.md)). Once finished, bring the `resolvectl monitor` process to the foreground:

```console
$ fg
```

Press `CTRL`+`c` to stop the query monitoring. The file `/tmp/resolvectl.monitor.log` contains the results. Run the following command to output the status of the queries where the status is not "`success`":

```console
$ cat /tmp/resolvectl.monitor.log | egrep "S: " | grep -v success
```

The number of lines matches the number of errors that occurred during the test. Investigate the file `/tmp/resolvectl.monitor.log` further:

```text
→ Q: <rds-aurora-endpoint> IN A
→ Q: <rds-aurora-endpoint> IN AAAA
← S: EINVAL
← A: <rds-aurora-endpoint> IN CNAME <...>
← A: <...> IN A <rds-aurora-ip>
```

Note the status `EINVAL` sent from the DNS.
