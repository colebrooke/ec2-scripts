# ec2-scripts

This is a set of scripts to help running a fleet of VMs in AWS EC2, and using S3 too :)

### list-ec2.sh

List running EC2 instances, within a certain region, using a certain AWS account profile.

Options:

```sh
#       OPTIONS
#
#       -p      Optional. Set desired AWS credentials profile. If not given, script will use ALL profiles.
#               Note: to set up a new profile use "aws configure --profile"
#
#       -r      Optional. Set desired AWS region. If not given, the script will use ALL regions.
#
#       EXAMPLE
#
#       List all running EC2 instances in us-east-1 region, using myprofile AWS connection credentials:
#       ./list-ec2.sh -p myprofile -r us-east-1
#
#       List all running EC2 instances in all regions, atempt to use all available AWS connection credentials:
#       ./list-ec2.sh
```


Example output:

```sh
local:~/ec2-scripts> ./list-ec2.sh my-profile eu-west-1
i-07ea1948465a8c791    	t2.micro       	10.12.31.109 T-XD1-DEV-jumpserver-linux-az1
i-0b3513445b0395b76    	t2.micro       	10.12.31.5 L-XD1-DEV-DOCKER-DOC-API
i-017c194c8dabae022    	t2.micro       	10.12.36.237 L-XD1-DEV-DOCKER-ENV1
i-09731f640b05d19b2    	t2.medium      	10.12.35.86 L-XD2-DEV-DOCKER-ENV2
i-00e31927b3d1bc8cf    	t2.micro       	10.12.31.59 L-XD1-DEV-orientdb
i-02df1b72a41af78f4    	t2.medium      	10.12.31.4 L-XD1-DEV-mongox
local:~/ec2-scripts>
```

### ls-s3-sizes.sh

OK, not strictly an EC2 related script, but handy if you're using S3 Object based storage and you want to calculate file sizes quickly, without traversing every object in the filestore.  The data comes from cloudwatch, and can be a little out of date verses what's actually in the bucket.

Usage:

```sh
# Usage:
#       ./ls-s3-sizes.sh
#
# TODO: Could be further parameterised depending on usage requirements.

PROFILE="default" # update to relect the Credentials profile you'd like to use, typicaly in ~/.aws/credentials
REGION="eu-west-1" # specify a region
STORAGE_CLASS="StandardIAStorage" # a storage class is required.  Either "StandardStorage" or "StandardIAStorage" for infrequent access
SHOW_ZERO_SIZE_BUCKETS="false"
```

Example output:

```sh
local:~> ./ls-s3-sizes.sh
.20GB - my-first-bucket-001
3.31GB - my-other-bucket-002
1.00GB - some-other-bucket-008
4.51GB - GRAND TOTAL
local:~>
```


