#!/bin/bash

# list available AWS regions
REGIONS=$(aws ec2 describe-regions --region us-east-1 | awk '{print $NF}')


# list running machines in each region
for REGION in $REGIONS[*]; do
	echo "$REGION"
	echo "=================="
	aws ec2 describe-instances --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --filters Name=instance-state-name,Values=running --output json --region $REGION --output text
	echo ""
done

