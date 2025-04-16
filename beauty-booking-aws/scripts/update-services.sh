#!/bin/bash

# aws-credentials.sh - Helper script to set up AWS credentials for deployment
# Usage: source ./scripts/aws-credentials.sh [profile]

# Check if profile parameter is provided
if [ $# -eq 1 ]; then
  PROFILE="$1"
  echo "Using AWS profile: $PROFILE"
  export AWS_PROFILE="$PROFILE"
else
  echo "Using default AWS profile"
  unset AWS_PROFILE
fi

# Verify AWS credentials
if aws sts get-caller-identity &>/dev/null; then
  AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text)
  AWS_USER=$(aws sts get-caller-identity --query "Arn" --output text)
  AWS_REGION=$(aws configure get region)
  
  echo "✅ AWS credentials verified successfully"
  echo "Account: $AWS_ACCOUNT"
  echo "User: $AWS_USER"
  echo "Region: $AWS_REGION"
else
  echo "❌ AWS credentials are not valid or not configured"
  echo "Please run 'aws configure' to set up your credentials"
  return 1
fi

# Display helpful commands
echo ""
echo "Useful commands:"
echo "  aws s3 ls                        # List S3 buckets"
echo "  aws ec2 describe-instances       # List EC2 instances"
echo "  aws ecs list-clusters            # List ECS clusters"
echo "  aws rds describe-db-instances    # List RDS instances"