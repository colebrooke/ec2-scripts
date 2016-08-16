#!/bin/bash

# quick script to show all EC2 instances (at least, the name tags!) running in all AWS regions...

type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required to rung this script."; exit 1; }

AVAILABLE_PROFILES=$(cat ~/.aws/config | grep profile | cut -d' ' -f2 | tr -d '[]')
echo "Avilable profiles:"
echo ${AVAILABLE_PROFILES[*]}
echo "Please enter the credentails profile you'd like to use:"
read PROFILE

REGIONS=$(aws ec2 describe-regions --region us-east-1 --output text | awk '{print $NF}')

# list running machines in each region
for REGION in ${REGIONS[*]}; do
        if [ -n $REGION ]; then
                echo "$REGION"
                echo "=================="
                aws ec2 describe-instances --profile $PROFILE --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --filters Name=instance-state-name,Values=running --output json --region $REGION --output text
                echo ""
        fi
done


