## Bring up a configured jenkins server

Make sure Ansible, Terraform and [terraform-coreos-box](https://github.com/Samsung-AG/terraform-provider-coreosbox) are installed  

Run:

    $ ./setup.sh --aws-key <aws key> --aws-secret <aws secret> --aws-region <aws region> \
      --aws-prefix testpipe --slack-token <slack api token> --github-id <github app id> \
      --github-key <github app key> --github-org <github org> --dump-data yes

### Try it out

Point your browser to

    https://pipelet.kubeme.io

After a self-signed cert SSL warning you should see the jenkins dashboard. Now try:


# To update in place

    ./setup.sh --aws-key <aws key> --aws-secret <aws secret> --aws-region <aws region> \
      --aws-prefix testpipe --slack-token <slack api token> --github-id <github app id> \
      --github-key <github app key> --github-org <github org> --dump-data no

No graceful termination / draining is in place, so coordinate with your team members accordingly

# To destroy
Run the terraform destroy command:

    ./destroy.sh --aws-key <aws key> --aws-secret <aws secret> --aws-region <aws region> \
      --aws-prefix testpipe --slack-token <slack api token> --github-id <github app id> \
      --github-key <github app key> --github-org <github org>

# Use environment variables

Instead of specifying all of the command line switches you can export the environment variables used in [utils](utils) file

# Terraform state

Currently no locking is implemented for the S3 state backend. Coordinate with your team members accordingly.
