#!/bin/bash

# various functions / utilities for AWS EC2

type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required to run this script."; exit 1; }

while getopts ":p:r:" OPT
do
	case $OPT in
		p)
			PROFIE=$OPTARG
			PROFILE_SET="true"
			;;

		r)
			REGION=$OPTARG
			REGION_SET="true"
			;;
	esac
done



function GetAvailableProfiles () {
	cat ~/.aws/config | grep profile | cut -d' ' -f2 | tr -d '[]'
}

function GetAvailableRegions () {
	aws ec2 describe-regions --region us-east-1 --output text | awk '{print $NF}'
}

function ListInstances () {

	PROFILE=$1
	REGION=$2
	aws ec2 describe-instances --profile $PROFILE \
                                --query 'Reservations[].Instances[].[InstanceId,InstanceType,PrivateIpAddress,Tags[?Key==`Name`].Value[]]' \
                                --filters Name=instance-state-name,Values=running \
                                --output=text --region $REGION \
                                | sed 's/None$/None\n/' | sed '$!N;s/\n/ /'

}

# both arguments supplied...
if [ ! -z $PROFILE ] && [ ! -z $REGION ]; then
	ListInstances $PROFILE $REGION

# just profile argument supplied...
elif [ ! -z $PROFILE ]; then

	REGIONS=$(GetAvailableRegions)
	for REGION in ${REGIONS[*]}; do
		ListInstances $PROFILE $REGION
	done

# just region argument supplied...
elif [ ! -z $REGION ]; then

	PROFILES=$(GetAvailableProfiles)
	for PROFILE in ${PROFILES[*]}; do
		ListInstances $PROFILE $REGION
	done

# no arguments, so try and use all profiles and all regions...
else
	PROFILES=$(GetAvailableProfiles)
	REGIONS=$(GetAvailableRegions)
	for PROFILE in ${PROFILES[*]}; do
	        for REGION in ${REGIONS[*]}; do
	                ListInstances $PROFILE $REGION
        	done
	done
fi


