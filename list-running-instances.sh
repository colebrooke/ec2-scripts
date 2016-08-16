#!/bin/bash

# quick script to show EC2 instances running in one AWS region (just the name tags!)

# optional, set profile
export AWS_DEFAULT_PROFILE=dr


REGIONS=$(aws ec2 describe-regions --region us-east-1 --output text | awk '{print $NF}')

echo "Availble regions:"
echo ${REGIONS[*]}

echo ""
echo "Please enter your selected region:"
read SELECTED_REGION
aws ec2 describe-instances --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --filters Name=instance-state-name,Values=running --output json --region $SELECTED_REGION --output text



