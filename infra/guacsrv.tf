# Guacamole server containing docker images.

data "template_file" "guacdeploy"{
  template = "${file("./guacdeploy.cfg")}"

  vars {
    db_ip = "${aws_db_instance.guacdb.address}"
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
  }
}

data "template_cloudinit_config" "guacdeploy_config" {
  gzip = false
  base64_encode = false

  part {
    filename     = "guacconfig.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.guacdeploy.rendered}"
  }
}

# Just going to deploy 1 guacamole server for now into one subnet, will add another soon 

resource "aws_instance" "guac-server1" {
  ami = "${var.guacsrv_ami}"
  vpc_security_group_ids = ["${aws_security_group.guac-sec.id}", "${aws_security_group.allout.id}"]
  instance_type = "${var.guacsrv_instance_type}"
  subnet_id = "${aws_subnet.priv_subnet1.id}"
  key_name = "${var.user_keyname}"
  tags {
    Name = "Guacamole Server 1"
  }
  depends_on = ["aws_instance.bastion-server1"]
  user_data = "${data.template_cloudinit_config.guacdeploy_config.rendered}"
}


resource "aws_security_group" "guac-sec" {
  name = "guacserver-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }
  #ssh from anywhere (just for testing)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }
}

#public access sg 

# allow all egress traffic (needed for server to download packages)
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
