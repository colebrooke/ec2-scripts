#!/bin/bash

# various functions / utilities for AWS EC2

type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required to rung this script."; exit 1; }

function GetAvailableProfiles() {
	cat ~/.aws/config | grep profile | cut -d' ' -f2 | tr -d '[]'
}

function GetAvailableRegions() {
	aws ec2 describe-regions --region us-east-1 --output text | awk '{print $NF}'
}

function ListInstances() {
aws ec2 describe-instances	--profile $PROFILE \
				--query 'Reservations[].Instances[].[PrivateIpAddress,InstanceId,Tags[?Key==`Name`].Value[]]' \
				--filters Name=instance-state-name,Values=running \
				--output=text --region $SELECTED_REGION \
				| sed 's/None$/None\n/' | sed '$!N;s/\n/ /'

}


