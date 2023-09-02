# Terraform Plan

## Summary

The [Git repository](https://github.com/schams-net/aws-ec2-rds-dns-lookup-issue) contains a Terraform plan that creates a basic environment containing the following components:

- VPC with 2x public subnets, route tables, 1x internet gateway, etc.
- 1x RDS Aurora Serverless v2 cluster with 1x DB instance (MySQL).
- 2x EC2 instances (1x Debian v11, 1x Debian v12) based on [Debian's official AMIs](https://wiki.debian.org/Cloud/AmazonEC2Image/).

This section describes how to deploy the infrastructure with Terraform on AWS.

## Requirements

An AWS account and an [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) with appropriate privileges (e.g. the `AdministratorRole`) are required to deploy the infrastructure stack. Apart from an AWS account, the following locally installed tools are required:

- [Terraform](https://www.terraform.io)
- [AWS CLI](https://aws.amazon.com/cli/)

The AWS Command Line Interface (AWS CLI) needs to be configured so that the CLI can interact with AWS. This includes, for example, the access credentials (access key ID and access secret key) and other configuration detail as required. See the [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for further details.

## Infrastructure Deployment

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

Terraform writes the **private** SSH key to `/tmp/private.pem`. Update the file permissions and use this key to login to the instance through SSH (see [How to Reproduce the Issue](how-to-reproduce-the-issue.md), section "Run the Queries (Test)").
