#!/bin/bash

# quick script to show EC2 instances running in one AWS region (just the name tags!)

type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required to run this script."; exit 1; }

AVAILABLE_PROFILES=$(cat ~/.aws/config | grep profile | cut -d' ' -f2 | tr -d '[]')
echo "Avilable profiles:"
echo ${AVAILABLE_PROFILES[*]}
echo "Please enter the credentails profile you'd like to use:"
read PROFILE

#export AWS_DEFAULT_PROFILE=dr

REGIONS=$(aws ec2 describe-regions --region us-east-1 --output text | awk '{print $NF}')
echo "Availble regions:"
echo ${REGIONS[*]}

echo ""
echo "Please enter your selected region:"
read SELECTED_REGION

echo ""

aws ec2 describe-instances	--profile $PROFILE \
				--query 'Reservations[].Instances[].[InstanceId,InstanceType,PrivateIpAddress,Tags[?Key==`Name`].Value[]]' \
				--filters Name=instance-state-name,Values=running \
				--output=text --region $SELECTED_REGION \
				| sed 's/None$/None\n/' | sed '$!N;s/\n/ /'

echo ""

# for reference, this command lists name tags only
#aws ec2 describe-instances --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --filters Name=instance-state-name,Values=running --output json --region $SELECTED_REGION --output text

# for reference, this command lists private network IPs only
#aws ec2 describe-instances --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' --output text  --region $SELECTED_REGION --filters Name=instance-state-name,Values=running 


