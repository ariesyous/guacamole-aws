# Apache Guacamole Deployment for AWS

## Overview

We'll deploy an RDS database, a guacd daemon and a Guacamole front end server, along with a Linux VM as the VDI server.

## Architecture
![Overview](https://raw.githubusercontent.com/aries-strato/guacamole-aws/master/diagram.png)

The infra folder contains scripts to deploy Guacamole infrastructure. The vdi folder contains scripts to run optional VDI infrastructure. 

## What we use

1 RDS instance (MySQL), 1 VPC, 6 subnets (2 public, 2 private, 2 for VDI), 2 NAT gateways, 1 ALB.

Terraform, Ubuntu Linux 16.04 LTS cloud image (for infra), internet connectivity. 


