## Bring up a configured jenkins server

Make sure [Homebrew](http://brew.sh/) is installed. Then run:
    
    $ ./setup.sh

Set the required environment vairables if/when the script complains about them.
    
### Try it out

Point your browser to

    https://pipelet.kubeme.io

After a self-signed cert SSL warning you should see the jenkins dashboard. Now try:

    http://pipelet.kubeme.io

You should be redirected to the https site. Login with your Github creds. 

    https://pipelet.kubeme.io/jobs/test 

Should be a valid job. Try running it.
    
    https://pipelet.kubeme.io/jobs/kraken_builder 

Should be a valid job. It should run every time someone opens a PR in the kraken repo

# To update in place

    ansible-playbook --inventory-file=inventory.ansible --private-key=~/.ssh/keys/krakenci/id_rsa playbooks/kraken-ci.yaml -vv --diff

Will sync local changes to jenkins instance, rebuild containers, and restart all processes.

TODO: you will likely need to Reload Configuration From Disk to pick up build history, it's unclear why that's not properly read in on startup.

No graceful termination / draining is in place, so coordinate with your team members accordingly

# To destroy
Run the terraform destroy command:

    terraform destroy -input=false

# Terraform state

Currently no locking is implemented for the S3 state backend. Coordinate with your team members accordingly.
