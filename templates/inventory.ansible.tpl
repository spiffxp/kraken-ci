ci ansible_ssh_host=${public_ip}

[coreos]
ci

[coreos:vars]
ansible_ssh_user=core
ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
docker_api_version=${docker_api_version}
hipchat_api_token=${hipchat_api_token}
hipchat_room_id=${hipchat_room_id}
vault_uri=${vault_uri}
vault_bucket=${vault_bucket}
access_key="${aws_key_id}"
secret_key="${aws_secret_access_key}"