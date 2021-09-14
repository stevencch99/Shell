#!/bin/bash
#
# Usage: `$ . ./get_aws_identity.sh <MFA_TOKEN_CODE>`
#    or: `$ source ./get_aws_identity.sh <MFA_TOKEN_CODE>`
#
# AWS cli credential configuration path: `~/.aws/credentials`
# Create a profile for "mfa": `$ aws configure --profile mfa`
# Check the environment variables about AWS: `$ printenv | grep AWS`
# Check if the session is valid: `$ aws sts get-caller-identity --profile mfa`
#
# Sample for getting temp session token from AWS STS
#
# aws --profile youriamuser sts get-session-token --duration 3600 \
# --serial-number arn:aws:iam::012345678901:mfa/user --token-code 012345
#
# Based on : https://github.com/EvidentSecurity/MFAonCLI/blob/master/aws-temp-token.sh
# Reference: https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2

DEBUG_MODE=false

# ===
# Using source approach to this script, so commented out below guard clauses
#
# if [ $? -ne 0 ]; then
#   echo "AWS CLI is not installed; exiting"
#   exit 1
# else
#   echo "Using AWS CLI found at $AWS_CLI"
# fi

# if [ $# -ne 1 ]; then
#   echo "Usage: . ./$0  <MFA_TOKEN_CODE>"
#   echo "Where:"
#   echo "   <MFA_TOKEN_CODE> = Code from virtual MFA device"
#   exit 2
# fi
# ===

# default user profile
AWS_USER_PROFILE=eagle_sch

# profile with session token
AWS_CLI_PROFILE=mfa
ARN_OF_MFA=arn:aws:iam::731873514506:mfa/stevenchang
MFA_TOKEN_CODE=$1
DURATION=129600

if $DEBUG_MODE
then
  echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
  echo "MFA ARN: $ARN_OF_MFA"
  echo "MFA Token Code: $MFA_TOKEN_CODE"
fi

# debug output
# set -x


read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$(aws --profile $AWS_USER_PROFILE sts get-session-token \
  --duration $DURATION  \
  --serial-number $ARN_OF_MFA \
  --token-code $MFA_TOKEN_CODE \
  --output text  | awk '{ print $2, $4, $5 }')

if $DEBUG_MODE
then
  echo "Debug 🙌"
  echo "AWS_ACCESS_KEY_ID: " $AWS_ACCESS_KEY_ID
  echo "AWS_SECRET_ACCESS_KEY: " $AWS_SECRET_ACCESS_KEY
  echo "AWS_SESSION_TOKEN: " $AWS_SESSION_TOKEN
fi

`aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile $AWS_CLI_PROFILE`
`aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile $AWS_CLI_PROFILE`
`aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile $AWS_CLI_PROFILE`

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# check validation of the mfa profile
aws sts get-caller-identity --profile mfa
