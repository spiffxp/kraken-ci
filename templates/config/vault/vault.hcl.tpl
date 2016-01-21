backend "s3" {
  bucket = "${vault_backend_bucket}"
  access_key = "${aws_access_key}"
  secret_key = "${aws_secret_key}"
  region = "${aws_region}"
}

listener "tcp" {
  address = "${vault_host_ip}:${vault_port}"
  tls_disable = 1
}
