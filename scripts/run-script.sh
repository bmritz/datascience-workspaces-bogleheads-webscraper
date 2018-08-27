#!/bin/bash

#$PROJECT_DIR is set in the compose/Dockerfile
PROCESS_SCRIPT_DIR=$PROJECT_DIR/process_scripts

#$SCRIPT is set as an environment variable when running the docker container
F=$PROCESS_SCRIPT_DIR/$SCRIPT

if [ -z "$SCRIPT" ] ; then
    echo "The environment variable SCRIPT is not specified. exiting with status code 1.."
    exit 1
fi

if [ -e $F ] ; then
    echo "RUNNING ${SCRIPT}..." 
    
    bash --login $F

    STATUS=$?

    else
    echo "SCRIPT $SCRIPT NOT FOUND..."
    STATUS=1
fi
exit $STATUS
