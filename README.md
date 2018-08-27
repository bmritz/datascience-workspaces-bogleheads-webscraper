bogleheads-webscraper
==============================

Demonstration of web-scraping using bogleheads.org posts for bitcoin


Project Organization
------------

    ├── LICENSE
    ├── README.md                       <- The top-level README for developers using this project.
    ├── compose
    │   ├── Dockerfile                  <- Dockerfile for running shell scripts in processes
    │   └── Dockerfile-dev              <- Dockerfile for ipython shell and jupyter noteboook
    ├── envs                            <- folder to house env files with environment variables for container, can concat multiple envs wiht run-cloud.sh
    ├── docker-compose.yml              <- Specifies services "run-script", "ipython-shell", "encrypt-secrets", & "jupyter-notebook"
    ├── project
    │   ├── data                        <- Data that is under source control. Import this path using: from config import DATA_DIR_GIT
    │   ├── models                      <- Trained and serialized models, model predictions, or model summaries
    │   ├── notebooks                   <- Jupyter notebooks go in this folder.
    │   │   └── config_nb.py            <- To get config over to notebooks
    │   ├── process_scripts             <- Shell scripts that will be run as processes
    │   ├── references                  <- Data dictionaries, manuals, and all other explanatory materials.
    │   ├── reports                     <- Generated analysis as HTML, PDF, LaTeX, etc., may also be notebooks
    │   │   └── figures                 <- Generated graphics and figures to be used in reporting
    │   ├── requirements.txt
    │   └── src                         <- Source code for use in this project.
    │       ├── __init__.py
    │   └── tests                       <- Tests for your project
    ├── requirements                    <- The requirements files for reproducing the analysis environment
    │   ├── base.txt                    <- Base imports needed by both a process and dev
    │   └── dev.txt                     <- Imports only needed for development, such as jupyter (possibly)
    ├── run-cloud.sh                    <- run the image in on google container engine
    ├── build-push.sh                   <- build and push the image to google container registry so it can be run on the cloud
    ├── make-live-env.sh                <- concat >=1 env files in the envs folder into one env file for running interactively locally
    ├── get-logs.sh                     <- get log entries for a specific cloud run -- ex: ./get-logs.sh <gce instance name>
    ├── scripts                         <- Scripts to run inside the container for processes
    │   ├── entrypoint.sh               <- Entrypoint for container commands -- Wraps command that emits SUCCEEDED or FAILED
    │   ├── run-script.sh               <- Script to run a shell script inside a container, runs the program defined by env var $SCRIPT inside the container
    │   └── encrypt-secrets.sh          <- Uses google cloud KMS to encrypt secret data stored in secrets/secrets.json to be put into a public env
    ├── secrets                         <- Directory to keep your secret data. 
    │   └── secrets.json                <- Make a file called secrets.json, and add in a json object with your secrets. The encrypt-secrets script looks here.
    └── env-public                      <- Environement variables for the container. Docker Compose services automatically load env vars from here by default.
   
   
The top level directory `project` is where you will do most of your coding. 

Environment Variables in the Containers
------------
Set all environment variables desired in the `env-public` file. This is set in `docker-compose.yml` to be parsed as a docker env file to load environment variables into each container. 

Secrets in the Containers
------------
The environment variable `CIPHERTEXT` is a special variable that should hold encrypted secrets to pass into the containers. The `CIPHERTEXT` variable will be unencrypted on container start up, with the result stored in the environment variable called SECRETS. To correctly encrypt data to put into `CIPHERTEXT`:
- Create a file in the `secrets` directory named `secrets.json`
- Write secret data to `secrets/secrets.json`
- Make sure you have the correct google authorization locally
- Create a Google KMS Key for Encryption/Decripytion (See Creating a Google KMS Key for Encryption/Decryption)
- Run the command `docker-compose run encrypt-secrets` to encrypt the data in `secrets/secrets.json`
- Copy and paste the CIPHERTEXT output of `docker-compose run encrypt-secrets` into `env-public`
- Test that you have access to the `SECRETS` env var inside the container by running `docker-compose run run-script env`


Creating a Google KMS Key for Encryption/Decryption
------------
Authenticate using the service account you would like to use for encryption decryption. (See Working with Google Authentication)
Create a key for your username:
In your local terminal: `gcloud kms keys create <KEYNAME> --location global --keyring <KEYRING>  --purpose encryption`
Store the KEYNAME and KEYRING as the `KEYNAME` and `KEYRING` env vars in `env-public` where the container will be able to read them for decryption inside the container.


Working with Google Authentication
------------
This project will mount ~/.config/glcoud into /root/.config/gcloud when using the `docker-compose run` command locally for local authentication, essentially passing through the local gcloud authentication state to the container for local development. When running on google compute engine, you do not need to mount this directory, as compute engine instances already have authorization "built" in at the VM level.

To use a service account:
-  copy the service account json file to ~/.config/gcloud/application-default-credentials.json on your machine (this is where google client libraries look for credentials by default) 
-  authorize gcloud with `gcloud auth activate-service-account --key-file ~/.config/gcloud/application-default-credentials.json` (this authorizes gcloud and sets up other files in `~/.config/gcloud` to reflect that authorization)  
-  Now, use the `docker-compose run` to run containers. Since `~/.config/gcloud` is mounted in, the container will be authorized.


Building Images for the project
------------
`cd` to the directory where you want the project to live.  
Clone this repository.  
Install docker and docker compose.  
Copy your bitbucket ssh private key to `secrets/bitbucket-private-key`  
Run `touch .env` to create an empty private env file at the root of this directory.  
Run `docker-compose build` to build the images for this project.  


Dockerfile Explanation
------------
The Dockerfiles for the images are found in the compose directory. The `run-script` service builds from the `compose/Dockerfile`, while `ipython-shell` and `jupyter-notebook` build from `compose/Dockerfile-dev`.
Make any changes you want to them to install any software you might need.  
Both Dockerfiles will install all python modules found in the `requirements/base.txt` file -- specify any python modules you need for your code here.  
Modules found in `requirements/dev.txt` will only be installed in the `ipython-shell` and `jupyter-notebook` services. 

Docker-Compose Explanation
------------
By default, there are 4 docker-compose services specified in `docker-compose.yml`, all are based on the same base image given in `compose/Dockerfile`:
* `docker-compose run run-script` -- run a bash script in `project/process_scripts`
* `docker-compose run ipython-shell` -- receive an ipython terminal with working directory `project/`
* `docker-compose up jupyter-notebook` -- launch a jupyter environment with working directory `project/` (must manually open browser and copy/paste url given on launch)
* `docker-compose run encrypt-secrets` -- encrypt the secrets in secrets/secrets.json so you can put encrypted secrets in an env file to be decrypted inside the container.

You should run each of the above commands from the root of this repository, where docker-compose.yml sits.

The `run-script` service is created from `compose/Dockerfile`. The `ipython-shell` and `jupyter-notebook` services both use `compose/Dockerfile-dev`, which inherits from `compose/Dockerfile`. By default, `compose/Dockerfile-dev` only adds in jupyter as a python dependency, and does nothing else.
