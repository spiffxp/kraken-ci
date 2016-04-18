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
source "${my_dir}/utils.sh"

echo 'Installing local python requirements'
pip install -r requirements.txt

echo 'Running ansible'
ansible-playbook -vv --diff -i ansible/inventory.local ansible/jenkins-up.yaml
ansible-playbook -vv --diff --ssh-common-args '-o StrictHostKeyChecking=no' -i ansible/inventory.remote ansible/jenkins.yaml
