#cloud-config

---
coreos:
  hostname: ${hostname}
  ssh_authorized_keys:
    - ${jenkins_ssh_key}
  etcd2:
    name: etcd
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    initial-cluster: etcd=http://$private_ipv4:2380
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-peer-urls: http://$private_ipv4:2380,http://$private_ipv4:7001
    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
    initial-cluster-state: new
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
