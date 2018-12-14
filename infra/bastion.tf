# Deploy bastion
# The bastion also has to pull the db configuration script and run it the first time it's spawned. 

data "template_file" "bastdeploy"{
  template = "${file("./bastdeploy.cfg")}"

  vars {
    db_ip = "${aws_db_instance.guacdb.address}"
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
  }
}

data "template_cloudinit_config" "bastdeploy_config" {
  gzip = false
  base64_encode = false

  part {
    filename     = "bastdeploy.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.bastdeploy.rendered}"
  }
}

# Bastion server 1 
# We'll add another one later for more redundancy

resource "aws_instance" "bastion-server1" {
  ami = "${var.bastion_ami}"
  vpc_security_group_ids = ["${aws_security_group.bastion-sec.id}", "${aws_security_group.allout.id}"]
  instance_type = "${var.bastion_instance_type}"
  subnet_id = "${aws_subnet.pub_subnet1.id}"
  key_name = "${var.user_keyname}"

  tags {
    Name = "Guac Bastion 1"
  }
  depends_on = ["aws_db_instance.guacdb"]
  user_data = "${data.template_cloudinit_config.bastdeploy_config.rendered}"
}

# associate EIP with bastion 1
resource "aws_eip" "bastion1" {
  instance = "${aws_instance.bastion-server1.id}"
  vpc = true
}

resource "aws_security_group" "bastion-sec" {
  name = "bastion-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  #ssh from anywhere (unnecessary)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#public access sg 

# allow all egress traffic
resource "aws_security_group" "allout" {
  name = "allout-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
