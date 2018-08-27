#!/usr/bin/env bash
# Takes positional parameters that are the name of the env files in envs/ to use

# raises this error for some reason: ./run-cloud.sh: line 13: [: too many arguments
UNPACKED=$@
if [ -z "$UNPACKED" ]
then
	echo "ENV VARS NEEDED...PLEASE SPECIFY PARAMETERS"
	echo "EXITING..."
	exit 1
else
	echo "ENV VARS: $@"
fi

# prefix each parameter string with ./envs
fils=$(echo "$@" | sed 's/[^ ]* */.\/envs\/&/g')

LIVE_ENV_FILE=./envs/live
cat $fils > $LIVE_ENV_FILE

echo "LIVE ENVIRONMENT:"
echo ""
cat $LIVE_ENV_FILE
echo ""