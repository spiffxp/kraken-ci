variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "github_client_id" {}
variable "github_client_key" {}
variable "hipchat_api_token" {}

variable "coreos_ami" {
  default = "ami-f5a5a5c5"
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
  default = "terrapipelet.kubeme.io"
}
variable "vault_hostname" {
  default = "vault.kubeme.io"
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