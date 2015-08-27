variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "github_client_id" {}
variable "github_client_key" {}
variable "hipchat_api_token" {}
variable "hipchat_room_id" {
  default = "1515130"
}
variable "coreos_ami" {
  default = "ami-85ada4b5"
}
variable "aws_region" {
	default = "us-west-2"
}
variable "route53_zone_id" {
  default = "ZX7O08V47RE60"
}
variable "aws_vpc" {
  default = "vpc-0776f062"
}
variable "aws_ebs_size" {
  default = "100"
}
variable "aws_subnet_cidr" {
  default = "10.1.110.0/24"
}
variable "ci_hostname" {
  default = "pipelet.kubeme.io"
}
variable "vault_hostname" {
  default = "vault.kubeme.io"
}
variable "vault_port" {
  default = "8200"
}
variable "vault_backend_bucket" {
  default = "kube-vault"
}
variable "aws_key_name" {
  default = "pipelet_key"
}
variable "aws_secgroup_name" {
  default = "pipelet_secgroup"
}
variable "aws_instance_type" {
  default = "m3.large"
}
variable "docker_api_version" {
  default = "1.18"
}
variable "github_org" {
  default = "Samsung-AG"
}