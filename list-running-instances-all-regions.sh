#!/bin/bash

# quick script to show all EC2 instances (at least, the name tags!) running in all AWS regions...

REGIONS=$(aws ec2 describe-regions --region us-east-1 --output text | awk '{print $NF}')

# list running machines in each region
for REGION in ${REGIONS[*]}; do
        if [ -n $REGION ]; then
                echo "$REGION"
                echo "=================="
                aws ec2 describe-instances --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --filters Name=instance-state-name,Values=running --output json --region $REGION --output text
                echo ""
        fi
done


