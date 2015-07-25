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
    command = "mkdir -p config/data_volume/rendered/configs; echo '${self.rendered}' > config/data_volume/rendered/configs/config.xml"
  }
}

resource "template_file" "credentialsfile" {
  filename = "templates/credentials.tpl"

  vars {
    aws_key_id = "${var.aws_access_key}"
    aws_secret_access_key = "${var.aws_secret_key}"
  }

  provisioner "local-exec" {
    command = "echo '${self.rendered}' > config/jenkins/credentials"
  }
}

resource "template_file" "hipchatconfig" {
  filename = "templates/jenkins.plugins.hipchat.HipChatNotifier.xml.tpl"

  vars {
    hipchat_api_token = "${var.hipchat_api_token}"
  }

  provisioner "local-exec" {
    command = "mkdir -p config/data_volume/rendered/configs; echo '${self.rendered}' > config/data_volume/rendered/configs/jenkins.plugins.hipchat.HipChatNotifier.xml"
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
  name = "${var.aws_secgroup_name}"
  description = "Security group for Samsung AG Jenkins server"
  vpc_id = "${var.aws_vpc}"

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

resource "aws_key_pair" "pipelet_keypair" {
  key_name = "${var.aws_key_name}"
  public_key = "${file("config/jenkins/keys/id_rsa.pub")}"
}

resource "aws_instance" "pipelet_ec2" {
  depends_on = "template_file.cloudconfig"
  ami = "${var.coreos_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name = "${aws_key_pair.pipelet_keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.pipelet_secgroup.id}" ]
  subnet_id = "${aws_subnet.pipelet_subnet.id}"
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "${var.aws_ebs_size}"
  }
  user_data = "${template_file.cloudconfig.rendered}"
  tags {
    Name = "${var.ci_hostname}"
  }
}

resource "aws_eip" "pipelet_eip" {
  instance = "${aws_instance.pipelet_ec2.id}"
  vpc = true

  provisioner "file" {
    source = "config"
    destination = "~"
    connection {
      type="ssh"
      host = "${aws_eip.pipelet_eip.public_ip}"
      user = "core"
      key_file ="~/.ssh/keys/krakenci/id_rsa"
    }
  }
}

resource "aws_route53_record" "pipelet_route" {
  zone_id = "${var.route53_zone_id}"
  name = "${var.ci_hostname}"
  type = "A"
  ttl = "30"
  records = ["${aws_eip.pipelet_eip.public_ip}"]

  provisioner "local-exec" {
    command = "echo '${var.ci_hostname}' > inventory.ansible"
  }

  provisioner "local-exec" {
    command = "ansible-playbook --inventory-file=inventory.ansible --user=core --private-key=~/.ssh/keys/krakenci/id_rsa playbooks/kraken-ci.yaml"
  }
}

