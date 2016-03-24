provider "aws" {
  access_key = "${var.aws_key}"
  secret_key = "${var.aws_secret}"
  region = "${var.aws_region}"
}

resource "coreosbox_ami" "coreos_ami" {
  channel        = "${var.coreos_channel}"
  virtualization = "hvm"
  region         = "${var.aws_region}"
  version        = "${var.coreos_version}"
}

resource "template_file" "cloudconfig" {
  template = "templates/cloud-config.tpl"

  vars {
    hostname = "${var.ci_hostname}"
    jenkins_ssh_key = "${var.jenkins_ssh_key}"
  }
}

resource "template_file" "ansible_inventory" {
  template = "${path.module}/templates/inventory.remote.tpl"

  vars {
    public_ip = "${aws_instance.jenkins_ec2.public_ip}"
    private_jenkins_ssh_key = "${var.private_jenkins_ssh_key}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/../ansible/inventory.remote\n${self.rendered}\nEOF"
  }
}

resource "aws_subnet" "jenkins_subnet" {
  vpc_id = "${var.aws_vpc}"
  cidr_block = "${var.aws_subnet_cidr}"

  tags {
      Name = "${var.ci_hostname} subnet"
  }
}

resource "aws_security_group" "jenkins_secgroup" {
  name = "${var.aws_secgroup_name}"
  description = "Security group for ${var.ci_hostname} Jenkins server"
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
    Name = "${var.ci_hostname} security group"
  }
}

resource "aws_key_pair" "jenkins_keypair" {
  key_name = "${var.aws_key_name}"
  public_key = "${file(var.jenkins_ssh_key)}"
}

resource "aws_instance" "jenkins_ec2" {
  depends_on = ["template_file.cloudconfig", "template_file.cloudconfig"]
  ami = "${coreosbox_ami.coreos_ami.box_string}"
  instance_type = "${var.aws_instance_type}"
  key_name = "${aws_key_pair.jenkins_keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.jenkins_secgroup.id}" ]
  subnet_id = "${aws_subnet.jenkins_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "${var.aws_ebs_size}"
  }
  user_data = "${template_file.cloudconfig.rendered}"
  disable_api_termination = "true"
  tags {
    Name = "${var.ci_hostname}"
  }
}

resource "aws_route53_record" "pipelet_route" {
  depends_on = ["aws_instance.jenkins_ec2", "template_file.ansible_inventory"]
  zone_id = "${var.route53_zone_id}"
  name = "${var.ci_hostname}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.jenkins_ec2.public_ip}"]
}

resource "aws_s3_bucket" "pipelet_clusters_bucket" {
  bucket = "${var.clusters_bucket}"
  acl = "private"
}

