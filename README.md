# kraken-ci

## Bring up a configured jenkins server

Make sure Ansible, Terraform and [terraform-coreos-box](https://github.com/samsung-cnct/terraform-provider-coreosbox) are installed  

Create an env file or otherwise populate your environment with the required secrets and settings.

    $ cat > .env-testpipe <<EOS
    export AWS_ACCESS_KEY_ID="<aws access key>"
    export AWS_SECRET_ACCESS_KEY="<aws secret key>"
    export AWS_DEFAULT_REGION="<aws region>"
    export SLACK_API_TOKEN="<slack api token>"
    export GITHUB_CLIENT_ID="<github app id>"
    export GITHUB_CLIENT_KEY="<github app key>"
    export GITHUB_ACCESS_TOKEN="<github token>"
    export GITHUB_USERNAME="<github user>"

    export CI_NAME="testpipe"
    EOS

Run:

    $ . .env-testpipe && ./setup.sh --dump-data yes

### Try it out

Point your browser to

    https://testpipe.kubeme.io

You should see the jenkins dashboard. Now try:


# To update in place

    $ . .env-testpipe && ./setup.sh --dump-data no

No graceful termination / draining is in place, so coordinate with your team members accordingly

# To destroy

    $ . .env-testpipe && ./destroy.sh

# To use test certificates

To test out / verify letsencrypt connectivity using their staging server, use the `--test-instance yes` flag or export `TEST_INSTANCE=yes`.  This will produce invalid certificates that may be rejected by your browser.

# Use environment variables

Instead of specifying all of the command line switches you can export the environment variables used in [utils.sh](utils.sh) file

# Known Issues

- Currently no locking is implemented for the S3 state backend. Coordinate with your team members accordingly.
