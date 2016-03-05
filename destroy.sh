#!/bin/bash -
#title           :destroy.sh
#description     :destroy a jenkins server in aws
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/utils"
ansible-playbook -i ansible/inventory.local --ssh-common-args '-o StrictHostKeyChecking=no' ansible/jenkins-down.yaml