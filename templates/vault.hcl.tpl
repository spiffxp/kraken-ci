backend "s3" {
  bucket = "kube-vault"
  access_key = "${aws_key_id}"
  secret_key = "${aws_secret_access_key}"
  region = "${aws_region}"
}

listener "tcp" {
  address = "${vault_host_ip}:${vault_port}"
  tls_cert_file = /vault_tls.crt
  tls_key_file = /vault_tls.key
}