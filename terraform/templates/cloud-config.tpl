#cloud-config

---
coreos:
  hostname: ${hostname}
  ssh_authorized_keys:
    - ${jenkins_ssh_key}
  etcd:
    # generate a new token for each unique cluster from https://discovery.etcd.io/new?size=3
    # specify the initial size of your cluster with ?size=X
    discovery: https://discovery.etcd.io/40c9c1017e889f34c5e70fd4812d0311
    # multi-region and multi-cloud deployments need to use $public_ipv4
    addr: $private_ipv4:4001
    peer-addr: $private_ipv4:7001
  units:
    - name: format-ebs.service
      command: start
      content: |
        [Unit]
        Description=Formats the EBS drive
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/sbin/wipefs -f /dev/xvdf
        ExecStart=/usr/sbin/mkfs.ext4 -F /dev/xvdf
    - name: var-lib-docker.mount
      command: start
      content: |
        [Unit]
        Description=Mount EBS to /var/lib/docker
        Requires=format-ebs.service
        After=format-ebs.service
        Before=docker.service
        [Mount]
        What=/dev/xvdf
        Where=/var/lib/docker
        Type=ext4
    - name: docker.service
      command: start
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start
  update:
    group: ${coreos_channel}
    reboot-strategy: ${coreos_reboot_strategy}
