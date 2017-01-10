kraken-ci

Continuous Integration (CI) testing for kraken and kraken 2. 

Note: kraken is deprecated and soon we will deprecate kraken related CI jobs also.

## Requirements

Install the following:

* Terraform v0.7.0 either by using:
    
    ```brew install terraform```
    
 or a release binary found [here](https://github.com/hashicorp/terraform/releases) or using a tool like: [tfenv](https://github.com/kamatama41/tfenv).
* terraform-provider-coreosbox:

    ```
    brew tap 'samsung-cnct/terraform-provider-coreosbox'
    brew install terraform-provider-coreosbox
    ```

  On a non-OSX platorm, follow the installation directions for [terraform](https://www.terraform.io/intro/getting-started/install.html) and then unzip the appropriate [release](https://github.com/samsung-cnct/terraform-provider-coreosbox/releases) of terraform-provider-coreosbox to the terraform path.

* Ansible and other tools:

  ```pip install -r requirements.txt```

  NOTE: If you are running in a virtualenv, you'll need to add `ansible_python_interpreter=${VIRTUAL_ENV}/bin/python` to `localhost`


## Configure and run jenkins server
In following the steps below, you will locally build a file containing your credentials for the following

  * [AWS](#aws)
  * [Slack](#slack)
  * [Github](#github)
  * [GKE/GCE](#gke/gce)
  
Before creating the file, you will need to prepare some credentials for each instance (considered unique by name) 
of kraken-ci:

* kraken-ci
  * choose a name for this instance, we'll call it "example-kraken-ci"
  * generate ssh keys: 
    
    ```mkdir -p keys && ssh-keygen -q -t rsa -N '' -C example-kraken-ci -f ./keys/id_rsa```
    
  * generate secrets:
    * TODO: how to generate jenkins secrets
    * TODO: how to generate docker/config.json
    * re-use secrets from a previous kraken-ci installation, we'll assume example-kraken-ci-prime
    * `aws s3 cp --recursive s3://sundry-automata/secrets/example-kraken-ci-prime.kubeme.io ./secrets`
  * create a pull request adding your own github id to `ansible/roles/ci-properties/defaults/main.yaml`
* kraken-ci-jobs
  * create a pull request adding your own github id to `jobs/samsung-cnct-project-pr.yaml`

Now we will gather the additional credentials used to build the file mentioned earlier:

#### AWS
* AWS_DEFAULT_REGION
  * choose a region, we'll assume "us-west-2"
* choose an s3 bucket, we'll assume "sundry-automata"
* upload generated ssh keys:

  ```aws s3 cp ./keys/* s3://sundry-automata/keys/example-kraken-ci.kubeme.io/```
  
* upload jenkins secrets

    ```aws s3 cp ./secrets/* s3://sundry-automata/secrets/example-kraken-ci.kubeme.io/```

* AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
  * choose/create an IAM user, we'll assume "example-aws-user"
  * update/create access credentials [here](https://console.aws.amazon.com/iam/home?region=us-west-2#users/example-aws-user)

#### Slack
To create `SLACK_API_TOKEN`:
* choose/create a slack team, we'll assume "example-team"
* manage apps for that team [here](https://example-team.slack.com/apps)
* add a jenkins-ci app
* choose a channel, we'll assume "#ping-jenkins"
* Locate and save the `Token` setting on the next page

#### Github
* choose/create a github org, we'll assume "example-org"
* choose/create a github user, we'll assume "example-github-user"
* ensure "example-github-user" is a member of "example-org"
* sign in as example-github-user, add generated ssh key (id_rsa.pub) via https://github.com/settings/keys
* GITHUB_CLIENT_ID, GITHUB_CLIENT_KEY
  * go to https://github.com/organizations/example-org/settings/applications
  * configure a new OAuth App
    * name: example-kraken-ci
    * url: http://example-kraken-ci.kubeme.io
    * description: example-kraken-ci instance of kraken-ci
    * callback url: http://example-kraken-ci.kubeme.io/securityRealm/finishLogin
  * look for the Client ID and Client Secret on the next page
* GITHUB_ACCESS_TOKEN
  * sign in as example-github-user, generate at https://github.com/settings/tokens
* GITHUB_USERNAME
  * this would be "example-github-user"

#### GKE/GCE
* Pick a "dev project" (we'll assume this to be k8s-work)
* Pick a "prod project" (we'll assume this to be cnct-productioncluster)
* Generate JSON-formatted keys for the 'Compute Engine default service account' (or another account with at least Editor access) for both projects
* GCE_SERVICE_ACCOUNT_ID - this is the id of the dev project Service Account (SA)
* GCE_PROD_SERVICE_ACCOUNT_ID - this is the id of the prod project SA
* Upload the dev project key to s3://sundry-automata/secrets/example-kraken-ci.kubeme.io/gcloud/service-account.json
* Upload the prod project key to s3://sundry-automata/secrets/example-kraken-ci.kubeme.io/gcloud/prod-service-account.json


### Build Credentials and Run
Create an env file or otherwise populate your environment with the required secrets and settings.

  ``` 
  cat > .env-example-kraken-ci <<EOS
    # project name
    export KRAKEN_CI_NAME="example-kraken-ci"
  
    # aws credentials
    export AWS_ACCESS_KEY_ID="<aws access key>"
    export AWS_SECRET_ACCESS_KEY="<aws secret key>"
    export AWS_DEFAULT_REGION="<aws region>"
  
    # slack credentials
    export SLACK_API_TOKEN="<slack api token>"
    
    # github credentials
    export GITHUB_CLIENT_ID="<github app id>"
    export GITHUB_CLIENT_KEY="<github app key>"
    export GITHUB_ACCESS_TOKEN="<github token>"
    export GITHUB_USERNAME="<github user>"
  
    # gce or gke credentials
    export GCE_SERVICE_ACCOUNT_ID="dev project service account id"
    export GCE_PROD_SERVICE_ACCOUNT_ID="prod project service account id"
    
    EOS
   ```

Run:
  
  ``` . .env-example-kraken-ci && ./setup.sh --dump-data yes```

## Webclient 
After building kraken-ci, to view the jenkins dashboard point your browser to

``` https://example-kraken-ci.kubeme.io ```


## Update In Place
No graceful termination/draining is in place, so coordinate with your team members accordingly

``` . .env-example-kraken-ci && ./setup.sh --dump-data no```


## Destroying

``` . .env-example-kraken-ci && ./destroy.sh```

## Test Certificates
To test out/verify let's encrypt connectivity using their staging server, use the `--test-instance yes` flag or export 
`TEST_INSTANCE=yes`.  This will produce invalid certificates that may be rejected by your browser.

## Environment Variables
Instead of specifying all of the command line switches you can export the environment variables used in [utils.sh](utils.sh) file

## Known Issues
* Currently no locking is implemented for the S3 state backend. Coordinate with your team members accordingly.
* jenkins secrets are manually generated
* docker/config.json generation is undocumented
