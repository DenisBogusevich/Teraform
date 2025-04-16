#!/bin/bash

# This script creates the S3 bucket and DynamoDB table for Terraform backend

set -e

# Check if environment name is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 dev"
  exit 1
fi

ENVIRONMENT=$1
REGION="us-east-1"
BUCKET_NAME="beauty-booking-terraform-state-dev-test-free${ENVIRONMENT}"
DYNAMODB_TABLE="beauty-booking-terraform-locks-${ENVIRONMENT}"

echo "Creating S3 bucket for Terraform state: ${BUCKET_NAME}"

# Create bucket with correct syntax for us-east-1 (no LocationConstraint)
if [ "$REGION" = "us-east-1" ]; then
  aws s3api create-bucket --bucket ${BUCKET_NAME} --region ${REGION}
else
  aws s3api create-bucket --bucket ${BUCKET_NAME} --region ${REGION} --create-bucket-configuration LocationConstraint=${REGION}
fi

# Enable bucket versioning
aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption --bucket ${BUCKET_NAME} --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'

# Block public access
aws s3api put-public-access-block --bucket ${BUCKET_NAME} --public-access-block-configuration '{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}'

echo "Creating DynamoDB table for state locking: ${DYNAMODB_TABLE}"
aws dynamodb create-table \
  --table-name ${DYNAMODB_TABLE} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ${REGION}

echo "Terraform backend infrastructure created successfully."
echo ""
echo "Add the following to your environments/${ENVIRONMENT}/providers.tf file:"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"${BUCKET_NAME}\""
echo "    key            = \"terraform.tfstate\""
echo "    region         = \"${REGION}\""
echo "    dynamodb_table = \"${DYNAMODB_TABLE}\""
echo "    encrypt        = true"
echo "  }"
echo "}"