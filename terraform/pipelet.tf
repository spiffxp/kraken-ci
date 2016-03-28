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

resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags {
    Name = "${var.ci_hostname}_vpc"
  }
}

resource "aws_vpc_dhcp_options" "jenkins_vpc_dhcp" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.ci_hostname}_dhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "jenkins_vpc_dhcp_association" {
  vpc_id          = "${aws_vpc.jenkins_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.jenkins_vpc_dhcp.id}"
}

resource "aws_internet_gateway" "jenkins_vpc_gateway" {
  vpc_id = "${aws_vpc.jenkins_vpc.id}"

  tags {
    Name = "${var.ci_hostname}_gateway"
  }
}

resource "aws_route_table" "jenkins_vpc_rt" {
  vpc_id = "${aws_vpc.jenkins_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jenkins_vpc_gateway.id}"
  }

  tags {
    Name = "{var.ci_hostname}_rt"
  }
}

resource "aws_security_group" "jenkins_secgroup" {
  name = "${var.aws_secgroup_name}"
  description = "Security group for ${var.ci_hostname} Jenkins server"
  vpc_id = "${aws_vpc.jenkins_vpc.id}"

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

resource "aws_subnet" "jenkins_subnet" {
  vpc_id = "${aws_vpc.jenkins_vpc.id}"
  cidr_block = "10.0.0.0/22"

  tags {
      Name = "${var.ci_hostname} subnet"
  }
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

