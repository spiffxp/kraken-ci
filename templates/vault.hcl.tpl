backend "s3" {
  bucket = "kube-vault"
  access_key = ${aws_key_id}
  secret_key = ${aws_secret_access_key}
}

listener "tcp" {
  address = "${vault_host_ip}:${vault_port}"
  tls_cert_file = /home/core/config/vault/tls/vault_tls.crt
  tls_key_file = /home/core/config/vault/tls/vault_tls.key
}