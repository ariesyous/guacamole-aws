# Provision networking resources for solution
# We need 1 VPC, 2 Public subnets (for load balancer and NAT GW), 2 Internal Subnet (for Guacamole and Database)
# And 2 VDI subnets


#provision app vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "192.168.0.0/16"
  assign_generated_ipv6_cidr_block = false
  enable_dns_support = true
  tags {
    Name = "Guacamole VDI VPC"
  }
}

#create igw
resource "aws_internet_gateway" "app_igw" {
  vpc_id = "${aws_vpc.app_vpc.id}"
}

# Pull data for AZs in region
data "aws_availability_zones" "available" {}

#provision public subnet 1
resource "aws_subnet" "pub_subnet1"{
  # Ensures subnet is created in it's own AZ
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.10.0/24"
  tags {
      Name = "public subnet 1"
  }
}

#public subnet 2
resource "aws_subnet" "pub_subnet2"{
  # Ensures subnet is created in it's own AZ
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.11.0/24"
  tags {
      Name = "public subnet 2"
  }
}

#provision VDI subnet 1
resource "aws_subnet" "vdi_subnet1" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "192.168.20.0/24"
  tags {
    Name = "VDI subnet 1"
  }
}

#provision VDI subnet 2
resource "aws_subnet" "vdi_subnet2" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "192.168.21.0/24"
  tags {
    Name = "VDI subnet 2"
  }
}


#provision private subnet #1
resource "aws_subnet" "priv_subnet1" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "192.168.30.0/24"
  tags {
    Name = "private subnet 1"
  }
}

#provision private subnet #2
resource "aws_subnet" "priv_subnet2" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "192.168.31.0/24"
  tags {
    Name = "private subnet 2"
  }
}

 #new default route table
resource "aws_default_route_table" "default" {
   default_route_table_id = "${aws_vpc.app_vpc.default_route_table_id}"

   route {
       cidr_block = "0.0.0.0/0"
       gateway_id = "${aws_internet_gateway.app_igw.id}"
   }
}

# provision EIP for nat gateway 1
resource "aws_eip" "gwip1" {
}

# provision EIP for nat gateway 1
resource "aws_eip" "gwip2" {
}

# NAT Gateway 1
resource "aws_nat_gateway" "gw1" {
  allocation_id = "${aws_eip.gwip1.id}"
  subnet_id = "${aws_subnet.pub_subnet1.id}"
  tags {
    Name = "NAT Gateway 1"
  }
}

# NAT Gateway 2
resource "aws_nat_gateway" "gw2" {
  allocation_id = "${aws_eip.gwip2.id}"
  subnet_id = "${aws_subnet.pub_subnet2.id}"
  tags {
    Name = "NAT Gateway 2"
  }
}

# Add route table for NAT GW 

resource "aws_route_table" "natroute1" {
  vpc_id = "${aws_vpc.app_vpc.id}"
   route {
       cidr_block = "192.168.0.0/16"
       gateway_id = "${aws_nat_gateway.gw1.id}"
   }
}
resource "aws_route_table" "natroute2" {
  vpc_id = "${aws_vpc.app_vpc.id}"
   route {
       cidr_block = "192.168.0.0/16"
       gateway_id = "${aws_nat_gateway.gw2.id}"
   }
}
# Associate VDI Subnets with AWS Route table for the NAT Gateway 
resource "aws_route_table_association" "vdi1" { 
  subnet_id = "${aws_subnet.vdi_subnet1.id}"
  route_table_id = "${aws_route_table.natroute1.id}"
}

resource "aws_route_table_association" "vdi2" { 
  subnet_id = "${aws_subnet.vdi_subnet2.id}"
  route_table_id = "${aws_route_table.natroute2.id}"
}

# Associate private subnets with NAT gw route tables

resource "aws_route_table_association" "int1" { 
  subnet_id = "${aws_subnet.priv_subnet1.id}"
  route_table_id = "${aws_route_table.natroute1.id}"
}

resource "aws_route_table_association" "int2" { 
  subnet_id = "${aws_subnet.priv_subnet2.id}"
  route_table_id = "${aws_route_table.natroute2.id}"
}





