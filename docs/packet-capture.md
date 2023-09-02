# Packet Capture

## Summary

This section documents how to enable DNS query logging and capture the network traffic for further analysis.

## Prerequisites

The infrastructure at AWS as described in the section [How to Reproduce the Issue](how-to-reproduce-the-issue.md), for example provisioned by the [Terraform plan](terraform-plan.md).

## Actions

### Enable DNS Query Logging

Execute the following command to enable DNS query logging:

```console
$ sudo rndc querylog
```

### Packet Capture

Start packet capture (in the background) by executing the following ([tcpdump](https://www.tcpdump.org)) command:

```console
$ sudo tcpdump -ni any -w $(ec2metadata --instance-id).pcap &
```

Press `ENTER` twice to return to the command prompt and run the tests again (see section [How to Reproduce the Issue](how-to-reproduce-the-issue.md)). After that, bring the `tcpdump` process to the foreground:

```console
$ fg
```

Press `CTRL`+`c` to stop the packet capture. The file `<instance-id>.pcap` in the current directory contains the captured packets.
