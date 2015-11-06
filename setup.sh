#!/bin/bash

# a few simple checks first
: ${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID first"}
: ${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY first"}
: ${AWS_DEFAULT_REGION:?"Set AWS_DEFAULT_REGION first"}
: ${TF_VAR_github_client_id:?"Set TF_VAR_github_client_id first"}
: ${TF_VAR_github_client_key:?"Set TF_VAR_github_client_key first"}
# : ${TF_VAR_github_org_token:?"Set TF_VAR_github_org_token first"}
: ${TF_VAR_hipchat_api_token:?"Set TF_VAR_hipchat_api_token first"}
: ${TF_VAR_slack_api_token:?"Set TF_VAR_slack_api_token first"}

brew tap Homebrew/bundle
brew bundle

echo 'donwloading keys and certificates'
aws s3 cp s3://sundry-automata/certs/pipelet/pipelet.kubeme.io.key $(pwd)/config/nginx/certs/
aws s3 cp s3://sundry-automata/certs/pipelet/pipelet.kubeme.io.crt $(pwd)/config/nginx/certs/
aws s3 cp s3://sundry-automata/certs/vault/vault.kubeme.io.key $(pwd)/config/nginx/certs/
aws s3 cp s3://sundry-automata/certs/vault/vault.kubeme.io.crt $(pwd)/config/nginx/certs/
aws s3 cp s3://sundry-automata/keys/jenkins/id_rsa $(pwd)/config/jenkins/keys/
aws s3 cp s3://sundry-automata/keys/jenkins/id_rsa.pub $(pwd)/config/jenkins/keys/
aws s3 cp s3://sundry-automata/secrets/ $(pwd)/config/data_volume/jenkins_config/secrets --recursive

echo 'installing jenkins ssh keys'
mkdir -p ${HOME}/.ssh/keys/krakenci
cp -f $(pwd)/config/jenkins/keys/id_rsa ${HOME}/.ssh/keys/krakenci/
cp -f $(pwd)/config/jenkins/keys/id_rsa.pub ${HOME}/.ssh/keys/krakenci/
chmod 600 ${HOME}/.ssh/keys/krakenci/id_rsa
ssh-add ${HOME}/.ssh/keys/krakenci/id_rsa

echo 'configuring terraform remote state'
terraform remote config -backend=S3 -backend-config="bucket=sundry-automata" -backend-config="key=krakenci-terraform-state"
terraform remote pull

# set tf-specific vars
export TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID}
export TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY}

# turn off ansible key checking
export ANSIBLE_HOST_KEY_CHECKING=False

# run terraform
terraform plan -input=false
terraform apply -input=false
terraform remote push
