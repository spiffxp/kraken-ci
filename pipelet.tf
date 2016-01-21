provider "aws" {
  # configured via env vars:
  # - AWS_ACCESS_KEY_ID
  # - AWS_SECRET_ACCESS_KEY
  # - AWS_DEFAULT_REGION
}

resource "template_file" "cloudconfig" {
  template = "templates/systemd.config.tpl"

  vars {
    hostname = "${var.ci_hostname}"
    jenkins_ssh_key = "${file("config/jenkins/keys/id_rsa.pub")}"
  }
}

resource "template_file" "jenkinsconfig" {
  template = "templates/config/data_volume/rendered/configs/config.xml.tpl"

  vars {
    github_client_id = "${var.github_client_id}"
    github_client_key = "${var.github_client_key}"
  }

  provisioner "local-exec" {
    command = "mkdir -p config/data_volume/rendered/configs; cat << 'EOF' > config/data_volume/rendered/configs/config.xml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "jenkinslocation" {
  template = "templates/config/data_volume/rendered/configs/jenkins.model.JenkinsLocationConfiguration.xml.tpl"

  vars {
    ci_hostname = "${var.ci_hostname}"
  }

  provisioner "local-exec" {
    command = "mkdir -p config/data_volume/rendered/configs; cat << 'EOF' > config/data_volume/rendered/configs/jenkins.model.JenkinsLocationConfiguration.xml\n${self.rendered}\nEOF"
  }
}

/*
# TODO: this should be rendered out by ansible prior to building the vault image
#       that way ansible can pull in aws_* vars from env, something terraform
#       doesn't currently support
resource "template_file" "vaultconfig" {
  template = "templates/config/vault/vault.hcl.tpl"

  vars {
    # aws_access_key = "${var.aws_access_key}"
    # aws_secret_key = "${var.aws_secret_key}"
    # aws_region = "${var.aws_region}"
    vault_backend_bucket = "${var.vault_backend_bucket}"
    vault_host_ip = "0.0.0.0"
    vault_port = "${var.vault_port}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > config/vault/config.hcl\n${self.rendered}\nEOF"
  }
}
*/

resource "template_file" "slackconfig" {
  template = "templates/config/data_volume/rendered/configs/jenkins.plugins.slack.SlackNotifier.xml.tpl"

  vars {
    slack_api_token = "${var.slack_api_token}"
  }

  provisioner "local-exec" {
    command = "mkdir -p config/data_volume/rendered/configs; cat << 'EOF' > config/data_volume/rendered/configs/jenkins.plugins.slack.SlackNotifier.xml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "ansible_inventory" {
  template = "templates/inventory.ansible.tpl"

  vars {
    public_ip = "${aws_instance.pipelet_ec2.public_ip}"
    ci_host_dns = "${var.ci_hostname}"
    docker_api_version = "${var.docker_api_version}"
    slack_api_token = "${var.slack_api_token}"
    vault_uri = "https://${var.vault_hostname}"
    vault_bucket = "${var.vault_backend_bucket}"
    aws_region = "${var.aws_region}"
    github_org = "${var.github_org}"
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
  depends_on = ["template_file.cloudconfig", "template_file.jenkinsconfig"]
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
  disable_api_termination = "true"
  tags {
    Name = "${var.ci_hostname}"
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
    command = "ansible-playbook --inventory-file=inventory.ansible --private-key=~/.ssh/keys/krakenci/id_rsa playbooks/kraken-ci.yaml -vv --diff"
  }
}

resource "aws_s3_bucket" "pipelet_clusters_bucket" {
  bucket = "pipelet-clusters"
  acl = "private"
}

/*
resource "aws_route53_record" "vault_route" {
  depends_on = ["aws_instance.pipelet_ec2"]
  zone_id = "${var.route53_zone_id}"
  name = "${var.vault_hostname}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.pipelet_ec2.public_ip}"]

  provisioner "local-exec" {
    command = "ansible-playbook --inventory-file=inventory.ansible --private-key=~/.ssh/keys/krakenci/id_rsa playbooks/vault.yaml -vv --diff"
  }
}
*/

