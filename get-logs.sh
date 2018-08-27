#!/usr/bin/env bash
# Takes positional parameter that is name of the instance that you want logs for


gcloud logging read "jsonPayload.instance.name=$1" --freshness 10d --limit 250 --format json |
jq '.[]|.jsonPayload.data' |
awk '{print NR ":" $0}' - |
sort -t: -k 1nr,1 |
sed 's/^[0-9][0-9]*://'