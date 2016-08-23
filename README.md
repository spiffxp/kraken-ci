# kraken-ci

## Bring up a configured jenkins server

Install terraform (manually at the moment, since a required plugin only works with 0.6.16).  In this example, we're installing to `$HOME/bin`

    mkdir -p $HOME/bin && cd $HOME/bin
    wget -O terraform.zip https://releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_darwin_amd64.zip
    wget -O terraform-provider-coreosbox.tar.gz https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/v0.0.1/terraform-provider-coreosbox_darwin_amd64.tar.gz
    unzip terraform.zip && rm terraform.zip
    tar xzf terraform-provider-coreosbox.tar.gz && rm terraform-provider-coreosbox.tar.gz
    echo 'export PATH=$HOME/bin:PATH' >> ~/.bash_profile

Install ansible

    pip install -r requirements.txt

You'll need to pre-create some credentials for each instance of kraken-ci:

- kraken-ci
    - choose a name for this instance, we'll call it "example-kraken-ci"
    - generate ssh keys, eg: `mkdir -p keys && ssh-keygen -q -t rsa -N '' -C example-kraken-ci -f ./keys/id_rsa`
    - generate secrets
        - TODO: how to generate jenkins secrets
        - TODO: how to generate docker/config.json
        - re-use secrets from a previous kraken-ci installation, we'll assume example-kraken-ci-prime
        - `aws s3 cp --recursive s3://sundry-automata/secrets/example-kraken-ci-prime.kubeme.io ./secrets`
- AWS
    - choose a region, we'll assume "us-west-2"
    - make an s3 bucket: s3://example-kraken-ci-backup
    - choose an s3 bucket, we'll assume "sundry-automata"
    - upload generated ssh keys
        - `aws s3 cp ./keys/* s3://sundry-automata/keys/example-kraken-ci.kubeme.io/`
    - upload jenkins secrets
        - `aws s3 cp ./secrets/* s3://sundry-automata/secrets/example-kraken-ci.kubeme.io/`
    - AWS_DEFAULT_REGION
        - this would be "us-west-2"
    - AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
        - choose/create an IAM user, we'll assume "example-aws-user"
        - update/create access credentials at https://console.aws.amazon.com/iam/home?region=us-west-2#users/example-aws-user
- Slack
    - SLACK_API_TOKEN
        - choose/create a slack team, we'll assume "example-team"
        - manage apps for that team at https://example-team.slack.com/apps
        - add a jenkins-ci app
        - choose a channel, we'll assume "#pipeline"
        - look for the "Token" setting on the next page
- Github
    - choose/create a github org, we'll assume "example-org"
    - choose/create a github user, we'll assume "example-github-user"
    - ensure "example-github-user" is a member of "example-org"
    - sign in as example-github-user, add generated ssh key (id_rsa.pub) via https://github.com/settings/keys
    - GITHUB_CLIENT_ID, GITHUB_CLIENT_KEY
        - go to https://github.com/organizations/example-org/settings/applications
        - configure a new OAuth App
            - name: example-kraken-ci
            - url: http://example-kraken-ci.kubeme.io
            - description: example-kraken-ci instance of kraken-ci
            - callback url: http://example-kraken-ci.kubeme.io/securityRealm/finishLogin
        - look for the Client ID and Client Secret on the next page
    - GITHUB_ACCESS_TOKEN
        - sign in as example-github-user, generate at https://github.com/settings/tokens
    - GITHUB_USERNAME
        - this would be "example-github-user"

Create an env file or otherwise populate your environment with the required secrets and settings.

    $ cat > .env-example-kraken-ci <<EOS
    export AWS_ACCESS_KEY_ID="<aws access key>"
    export AWS_SECRET_ACCESS_KEY="<aws secret key>"
    export AWS_DEFAULT_REGION="<aws region>"
    export SLACK_API_TOKEN="<slack api token>"
    export GITHUB_CLIENT_ID="<github app id>"
    export GITHUB_CLIENT_KEY="<github app key>"
    export GITHUB_ACCESS_TOKEN="<github token>"
    export GITHUB_USERNAME="<github user>"

    export KRAKEN_CI_NAME="example-kraken-ci"
    EOS

Run:

    $ . .env-example-kraken-ci && ./setup.sh --dump-data yes

### Try it out

Point your browser to

    https://example-kraken-ci.kubeme.io

You should see the jenkins dashboard. Now try:


# To update in place

    $ . .env-example-kraken-ci && ./setup.sh --dump-data no

No graceful termination / draining is in place, so coordinate with your team members accordingly

# To destroy

    $ . .env-example-kraken-ci && ./destroy.sh

# To use test certificates

To test out / verify letsencrypt connectivity using their staging server, use the `--test-instance yes` flag or export `TEST_INSTANCE=yes`.  This will produce invalid certificates that may be rejected by your browser.

# Use environment variables

Instead of specifying all of the command line switches you can export the environment variables used in [utils.sh](utils.sh) file

# Known Issues

- Currently no locking is implemented for the S3 state backend. Coordinate with your team members accordingly.
- jenkins secrets are manually generated
- docker/config.json generation is undocumented
