## Bring up a configured jenkins server

Make sure Ansible, Terraform and [terraform-coreos-box](https://github.com/samsung-cnct/terraform-provider-coreosbox) are installed  

Create an env file or otherwise populate your environment with the required secrets, eg:

    $ cat > .env-testpipe <<EOS
    export AWS_ACCESS_KEY_ID="<aws access key>"
    export AWS_SECRET_ACCESS_KEY="<aws secret key>"
    export AWS_DEFAULT_REGION="<aws region>"
    export SLACK_API_TOKEN="<slack api token>"
    export GITHUB_CLIENT_ID="<github app id>"
    export GITHUB_CLIENT_KEY="<github app key>"
    export GITHUB_ACCESS_TOKEN="<github token>"
    export GITHUB_USERNAME="<github user>"
    EOS

Run:

    $ . .env-testpipe && ./setup.sh --ci-name testpipe --dump-data yes

### Try it out

Point your browser to

    https://testpipe.kubeme.io

After a self-signed cert SSL warning you should see the jenkins dashboard. Now try:


# To update in place

    $ . .env-testpipe && ./setup.sh --ci-name testpipe --dump-data no

No graceful termination / draining is in place, so coordinate with your team members accordingly

# To destroy
Run the terraform destroy command:

    $ . .env-testpipe && ./destroy.sh --ci-name testpipe

# Use environment variables

Instead of specifying all of the command line switches you can export the environment variables used in [utils.sh](utils.sh) file

# Terraform state

Currently no locking is implemented for the S3 state backend. Coordinate with your team members accordingly.
