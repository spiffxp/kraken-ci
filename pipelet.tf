provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "template_file" "cloudconfig" {
  filename = "templates/systemd.config.tpl"

  vars {
    hostname = "${var.ci_hostname}"
    jenkins_ssh_key = "${file("config/jenkins/keys/id_rsa.pub")}"
  }
}

resource "template_file" "jenkinsconfig" {
  filename = "templates/config.xml.tpl"

  vars {
    github_client_id = "${var.github_client_id}"
    github_client_key = "${var.github_client_key}"
  }

  provisioner "local-exec" {
    command = "echo ${self.rendered} >> private_ips.txt"
  }
}

resource "template_file" "hipchatconfig" {
  filename = "templates/credentials.tpl"
}

resource "template_file" "hipchatconfig" {
  filename = "templates/jenkins.plugins.hipchat.HipChatNotifier.xml.tpl"

  vars {
    hipchat_api_token = "${var.hipchat_api_token}"
  }
}

resource "aws_subnet" "pipelet_subnet" {
  vpc_id = "${var.aws_vpc}"
  cidr_block = "${var.aws_subnet_cidr}"

  tags {
      Name = "Pipelet subnet"
  }
}

resource "aws_security_group" "pipelet_secgroup" {
  name = "pipelet"
  description = "Security group for Samsung AG Jenkins server"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Pipelet security group"
  }
}

resource "aws_instance" "pipelet_ec2" {
	depends_on = "template_file.cloudconfig"
  ami = "${var.coreos_ami}"
  instance_type = "m3.large"
  key_name = "pipelet"
  vpc_security_group_ids = [ "${aws_security_group.pipelet_secgroup.id}" ]
  subnet_id = "${aws_subnet.pipelet_subnet.id}"
  user_data = "${template_file.cloudconfig.rendered}"
  tags {
	 Name = "${var.ci_hostname}"
	}
}

resource "aws_eip" "pipelet_eip" {
    instance = "${aws_instance.pipelet_ec2.id}"
    vpc = true
}

resource "aws_route53_record" "pipelet_route" {
  zone_id = "${var.route53_zone_id}"
  name = "${var.ci_hostname}"
  type = "A"
  ttl = "30"
  records = ["${aws_eip.pipelet_eip.public_ip}"]
}

