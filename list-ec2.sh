#!/bin/bash

#########################################################
# 	./list-ec2.sh 					#
#							#
# 	Script to list VMs running in EC2		#
#							#
# 	Author:  Justin Miller				#
# 	Website: https://github.com/colebrooke		#
# 							#
#########################################################


# 	OPTIONS
#
# 	-p  	Optional. Set desired AWS credentials profile. If not given, script will use ALL profiles.
#		Note: to set up a new profile use "aws configure --profile"
#
#	-r	Optional. Set desired AWS region. If not given, the script will use ALL regions.
#
#	EXAMPLE
#
#	List all running EC2 instances in us-east-1 region, using myprofile AWS connection credentials:
#	./list-ec2.sh -p myprofile -r us-east-1
#
#	List all running EC2 instances in all regions, atempt to use all available AWS connection credentials:
#	./list-ec2.sh
#

# check for aws command line utilities
type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required to run this script."; exit 1; }

#TODO: determine if local environment variables have been set for AWS keys
#      e.g. if [ ! -z $AWS_ACCESS_KEY_ID ] && [ ! -z $AWS_SECRET_ACCESS_KEY ]; then echo 'set'; else echo 'notset'; fi

REGION=""
PROFILE=""

while getopts ":p:r:" OPT
do
	case $OPT in
		p)
			PROFILE=$OPTARG
			;;

		r)
			REGION=$OPTARG
			;;
		v)
			#TODO: set more verbose output when required
			VERBOSE="true"
			;;
	esac
done

function GetAvailableProfiles () {
	# attempt to retreive profile information from home directory
	cat ~/.aws/config | grep profile | cut -d' ' -f2 | tr -d '[]'
}

function GetAvailableRegions () {
	# gets the list of all regions from AWS
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
		echo $PROFILE
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


