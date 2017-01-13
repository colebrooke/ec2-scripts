#!/bin/bash
# Justin Miller 12/01/17
# Script to calculate the human readable size of S3 buckets
# Usage:
#	./ls-s3-sizes.sh
#
# TODO: Could be further parameterised depending on usage requirements.

# AWS Credentails profile, AWS Region and S3 Storage Class need to be set.
PROFILE="dr"
REGION="eu-west-1"
STORAGE_CLASS="StandardIAStorage"
SHOW_ZERO_SIZE_BUCKETS="false"

# Check if jq is available
type jq >/dev/null 2>&1 || { echo >&2 "The jq utility is required for this script to run."; exit 1; }

# Check if aws cli is available
type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required for this script to run."; exit 1; }

BUCKETS=$(aws --profile $PROFILE s3 ls | cut -d' ' -f3)

function BucketSize () {
	BUCKET=$1
	NOW=$(date +%s)
	BUCKET_SIZE_BYTES=$(aws --profile $PROFILE cloudwatch get-metric-statistics --namespace AWS/S3 --start-time "$(echo "$NOW - 86400" | bc)" --end-time "$NOW" --period 86400 --statistics Average --region $REGION --metric-name BucketSizeBytes --dimensions Name=BucketName,Value="$BUCKET" Name=StorageType,Value=$STORAGE_CLASS | jq '.Datapoints[].Average')

	if [[ $BUCKET_SIZE_BYTES > 1 ]]; then
		BUCKET_SIZE_GB=$(echo "scale=2; $BUCKET_SIZE_BYTES/1073741824" | bc -l)
		echo -e "${BUCKET_SIZE_GB}GB - $BUCKET"
	else
		BUCKET_SIZE_GB=0
		if [ $SHOW_ZERO_SIZE_BUCKETS == "true" ]; then
			echo -e "${BUCKET_SIZE_GB}GB - $BUCKET"
		fi
	fi
}

TOTAL_SIZE=0
for MYBUCKET in ${BUCKETS[*]}; do
	BucketSize "$MYBUCKET"
	TOTAL_SIZE=$(echo "scale=2; $TOTAL_SIZE+$BUCKET_SIZE_GB" | bc -l)
done

echo "${TOTAL_SIZE}GB - GRAND TOTAL"



