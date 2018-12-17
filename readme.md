# Apache Guacamole Deployment for AWS

## Overview

This Terraform script will deploy a highly available Apache Guacamole environment into your AWS region of choice. O

## What's Guacamole? 

From https://guacamole.apache.org/ -   
"Apache Guacamole is a  **clientless remote desktop gateway**. It supports standard protocols like VNC, RDP, and SSH. We call it  _clientless_  because no plugins or client software are required. Thanks to HTML5, once Guacamole is installed on a server, all you need to access your desktops is a web browser."


## Architecture
![Overview](https://raw.githubusercontent.com/aries-strato/guacamole-aws/master/diagram.png)

The infra folder contains scripts to deploy Guacamole infrastructure. The vdi folder contains scripts to create the optional Linux VDI VM's based on Ubuntu. 

## What we use

1 RDS instance (MySQL), 1 VPC, 6 subnets (2 public, 2 private, 2 for VDI), 2 NAT gateways, 1 ALB.

Terraform, Ubuntu Linux 16.04 LTS cloud image to run the Guacamole containers is all that's needed to deploy it.  

## terraform.tfvars
Populate the file (terraform.tfvars.sample, and omit the .sample extension) with your respective input. You need to upload or generate a certificate via ACM or IAM for the ALB.

Also include the name of the keypair you would like to use for the bastion host.

The cloudinit scripts are written for Ubuntu Xenial (16.04 LTS) so use a cloud-enabled image for those. 



