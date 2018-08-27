#!/bin/bash

echo "Encrypting secret data in /secrets/secrets.json ..."

CIPHERTEXT=$(sed 's:^#.*$::g' /secrets/secrets.json | gcloud kms encrypt --ciphertext-file - --plaintext-file - --location global --key=$KEYNAME --keyring=$KEYRING | base64)
echo ""
echo "CIPHERTEXT:"
echo ""
echo $CIPHERTEXT
echo ""
echo 'Copy and paste the value below "CIPHERTEXT:" into the environment variable CIPHERTEXT to have the secrets available in the image'
