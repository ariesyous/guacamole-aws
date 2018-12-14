
#Provision load balancer and associated security group

###############################################
## SECURITY GROUP DEFINITION 
###############################################

resource "aws_security_group" "lb-sec" {
  name = "lb-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

 
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ping from anywhere
    ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}



###############################################
## ALB CONFIGURATION 
###############################################

resource "aws_alb" "alb" {
  subnets = ["${aws_subnet.pub_subnet1.id}","${aws_subnet.pub_subnet2.id}"]
  internal = false
  security_groups = ["${aws_security_group.lb-sec.id}"]
}

resource "aws_alb_target_group" "targ" {
  port = 8080
  protocol = "HTTP"
  vpc_id = "${aws_vpc.app_vpc.id}"
}

resource "aws_alb_target_group_attachment" "attach_web" {
  target_group_arn = "${aws_alb_target_group.targ.arn}"
  target_id = "${element(aws_instance.web-server.*.id, count.index)}"
  port = 8080
  count = "${var.web_number}"
}

resource "aws_alb_listener" "list" {
  "default_action" {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = 80
}



