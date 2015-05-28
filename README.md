## Bring up a configured jenkins server

First run vagrant:
    
    $ vagrant up
    
### Try it out

Point your browser to

    https://pipelet.kubeme.io

You should see the jenkins dashboard. No SSL warnings. Now try:

    http://pipelet.kubeme.io

You should be redirected to the https site. Login with your Github creds. 

    https://pipelet.kubeme.io/jobs/kraken_builder 

Should be a valid job. Try running it.
