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
    command = "mkdir -p config/data_volume/rendered/configs; cat << 'EOF' > config/data_volume/rendered/configs/config.xml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "credentialsfile" {
  filename = "templates/credentials.tpl"

  vars {
    aws_key_id = "${var.aws_access_key}"
    aws_secret_access_key = "${var.aws_secret_key}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > config/jenkins/credentials\n${self.rendered}\nEOF"
  }
}

resource "template_file" "vaultconfig" {
  filename = "templates/vault.hcl.tpl"

  vars {
    aws_key_id = "${var.aws_access_key}"
    aws_secret_access_key = "${var.aws_secret_key}"
    vault_host_ip = "${aws_instance.pipelet_ec2.private_ip}"
    vault_port = "${var.vault_port}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > config/vault/config.hcl\n${self.rendered}\nEOF"
  }
}

resource "template_file" "hipchatconfig" {
  filename = "templates/jenkins.plugins.hipchat.HipChatNotifier.xml.tpl"

  vars {
    hipchat_api_token = "${var.hipchat_api_token}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > config/data_volume/rendered/configs/jenkins.plugins.hipchat.HipChatNotifier.xml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "ansible_inventory" {
  filename = "templates/inventory.ansible.tpl"

  vars {
    public_ip = "${aws_instance.pipelet_ec2.public_ip}"
    ci_host_dns = "${var.ci_hostname}"
    docker_api_version = "${var.docker_api_version}"
    hipchat_api_token = "${var.hipchat_api_token}"
    hipchat_room_id = "${var.hipchat_room_id}"
    vault_uri = "https://${var.vault_hostname}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > inventory.ansible\n${self.rendered}\nEOF"
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
  depends_on = ["template_file.cloudconfig", "template_file.vaultconfig" "template_file.jenkinsconfig", "template_file.credentialsfile", "template_file.hipchatconfig"]
  ami = "${var.coreos_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name = "${aws_key_pair.pipelet_keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.pipelet_secgroup.id}" ]
  subnet_id = "${aws_subnet.pipelet_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "${var.aws_ebs_size}"
  }
  user_data = "${template_file.cloudconfig.rendered}"
  tags {
    Name = "${var.ci_hostname}"
  }

  provisioner "file" {
    source = "config"
    destination = "~"
    connection {
      type="ssh"
      host = "${self.public_ip}"
      user = "core"
      key_file ="~/.ssh/keys/krakenci/id_rsa"
    }
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install defunctzombie.coreos-bootstrap --force"
  }
}

resource "aws_route53_record" "pipelet_route" {
  depends_on = ["aws_instance.pipelet_ec2", "template_file.ansible_inventory"]
  zone_id = "${var.route53_zone_id}"
  name = "${var.ci_hostname}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.pipelet_ec2.public_ip}"]

  provisioner "local-exec" {
    command = "ansible-playbook --inventory-file=inventory.ansible --private-key=~/.ssh/keys/krakenci/id_rsa playbooks/kraken-ci.yaml -vvv"
  }
}

resource "aws_route53_record" "vault_route" {
  depends_on = ["aws_instance.pipelet_ec2"]
  zone_id = "${var.route53_zone_id}"
  name = "${var.vault_hostname}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.pipelet_ec2.public_ip}"]

  provisioner "local-exec" {
    command = "ansible-playbook --inventory-file=inventory.ansible --private-key=~/.ssh/keys/krakenci/id_rsa playbooks/vault.yaml -vvv"
  }
}

