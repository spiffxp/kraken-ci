#!/bin/bash -
#title           :setup.sh
#description     :bring up a jenkins server in aws
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/utils"

echo 'Running ansible'
ansible-playbook -i ansible/inventory.local ansible/jenkins-up.yaml
ansible-playbook -i ansible/inventory.remote --ssh-common-args '-o StrictHostKeyChecking=no' ansible/jenkins.yaml
