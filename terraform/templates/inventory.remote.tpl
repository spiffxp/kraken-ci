[ci]
jenkins ansible_ssh_host=${public_ip} ansible_ssh_user=core ansible_ssh_private_key_file=${private_jenkins_ssh_key} ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
