variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "github_client_id" {}
variable "github_client_key" {}
variable "hipchat_api_token" {}

variable "coreos_ami" {
    default = "ami-bf8477fb"
}
variable "aws_region" {
	default = "us-east-2"
}
variable "route53_zone_id" {
  default = "ZX7O08V47RE60"
}
variable "aws_vpc" {
  default = "vpc-0776f062"
}
variable "aws_subnet_cidr" {
  default = "10.1.105.0/24"
}
variable "ci_hostname" {
  default = "pipelet.kubeme.io"
}