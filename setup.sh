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
pip install -qr requirements.txt

echo 'checking provider pre-requsites'
if ! which terraform-provider-coreosbox > /dev/null; then
  echo "please install the provider: 'terraform-provider-coreosbox' as documented in README.md"
  exit 1
fi

echo 'Running ansible'
ansible-playbook -${ANSIBLE_VERBOSITY} --diff -i ansible/inventory.local ansible/jenkins-up.yaml
ansible-playbook -${ANSIBLE_VERBOSITY} --diff --ssh-common-args '-o StrictHostKeyChecking=no' -i ansible/inventory.remote ansible/jenkins.yaml
