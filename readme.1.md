# Guacamole Infra deployment

  This folder has all of the components to deploy the actual infrastructure powering the VDI environment. Everything you need minus the VDI machines themselves. 

## terraform.tfvars
Populate the file (terraform.tfvars.sample, and omit the .sample extension) with your respective input. You need to upload or generate a certificate via ACM or IAM for the ALB.

Also include the name of the keypair you would like to use for the bastion host.





  
