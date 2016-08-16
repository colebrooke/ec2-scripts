#!/bin/bash

# quick script to get logs from a running instance

if [ "$#" -ne 3 ]; then echo "Usage:  ./get-logs.sh <profile> <region> <some-instance-id>"; exit; fi

PROFILE=$1
REGION=$2
INSTANCE_ID=$3
aws ec2 get-console-output --profile $1 --region $REGION --instance-id $3 --output text
