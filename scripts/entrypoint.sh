#!/bin/bash --login

# set +e will continue the program if there is an error (so it will self destruct even if cmd fails)
set +e
cmd="$@"

export SECRETS="$(echo $CIPHERTEXT | base64 -di | gcloud kms decrypt --ciphertext-file - --plaintext-file - --location global --key=$KEYNAME --keyring=$KEYRING)"

# this wraps the command so we get an exit code
$cmd

STATE=$?

## NOTE: BECAUSE WE ARE RUNNING with -e, 'FAILED' will never actually be echoed, because the $cmd stops this script if it fails
if [ $STATE -eq 0 ] ; then 
  echo 'SUCCEEDED'
else 
  echo 'FAILED'
fi


## code below is to self-delete the instance when running on gce
#query apis to get instance metadata -- 
INSTANCE_NAME=$(curl -fs "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
ZONE_NAME=$(curl -fs "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor:Google")

## get zone name from the end of ZONE_NAME string -- bash string manipulation -- will also be empty if not on google cloud
myZone="${ZONE_NAME##*/*/}"

# call to delete itself if we are on google cloud
if [ -z "$myZone" ]
then
      exit $STATE
else
      gcloud compute instances delete $INSTANCE_NAME --zone=$myZone --quiet
fi
