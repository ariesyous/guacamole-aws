
# Apache Guacamole Deployment for AWS using Terraform and Cloudinit

## Overview

This Terraform script will deploy Apache Guacamole environment into your AWS region of choice. 

## What's Guacamole?

From https://guacamole.apache.org/ -

"Apache Guacamole is a **clientless remote desktop gateway**. It supports standard protocols like VNC, RDP, and SSH. We call it _clientless_ because no plugins or client software are required. Thanks to HTML5, once Guacamole is installed on a server, all you need to access your desktops is a web browser."

## Architecture

![Overview](https://raw.githubusercontent.com/aries-strato/guacamole-aws/master/diagram.png)

The infra folder contains scripts to deploy Guacamole infrastructure. The vdi folder contains scripts to create the optional Linux VDI VM's based on Ubuntu.

## What we use

1 RDS instance (MySQL), 1 VPC, 6 subnets (2 public, 2 private, 2 for VDI), 2 NAT gateways, 1 ALB.

Terraform, Ubuntu Linux 16.04 LTS cloud image to run the Guacamole containers is all that's needed to deploy it.

## terraform.tfvars

Populate the file (terraform.tfvars.sample, and omit the .sample extension) with your respective input. You need to upload or generate a certificate via ACM or IAM for the ALB.

Also include the name of the keypair you would like to use for the bastion host. The same keypair will be injected into the Guacamole server as well (in case you ever need to SSH into it). 

The cloudinit scripts are written for Ubuntu Xenial (16.04 LTS) so use a cloud-enabled image for those.

## Getting VDI images connected
It's your responsibility to create VDI images (whether they are Linux or Windows based) and spawn them in the relevant subnets that get created in their respective AZ. There's no automation (yet) to connect and automatically add the images to the Guacamole server, so it's a manual process - but the good news is the configuration state is always stored in the MySQL database so as long as this is backed up and kept up to date - this configuration can be done once and kept persistent. You can refer to the Guacamole documentation, specifically the API documentation to take this concept further - https://guacamole.apache.org/api-documentation/.

## Network connectivity 

By default - the Guacamole servers have connectivity to the VDI images since they should all be in the proper subnets and routing using the IGW for the VPC that gets created. Security groups should prevent any other VM's from accessing them. 

## Some additional notes / next steps / things to improve

I'd like to configure elastic load balancing and auto scaling to work together and spawn more guacd/guacamole servers as needed. Another option is using something like AWS Fargate or Kubernetes to manage the containers, rather then just deploying them into single EC2 instances per AZ in a region. 

I've only configured the script to use the first two AZ's available in a region, but this can be extended to 3 or more, depending on the region - and would require some additional coding. Another MySQL read-replica can be set up to run in another region as well - or rather then using an on-demand MySQL instance one can use Aurora Serverless. 

The bastion server is also single instance - so if an AZ goes down with your bastion it kind of puts you out of comission until that AZ comes back up. To fix this, just deploy another bastion into the other public subnet and give it an EIP. 

