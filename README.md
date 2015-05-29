## Bring up a configured jenkins server

First run vagrant:
    
    $ vagrant up
    
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
