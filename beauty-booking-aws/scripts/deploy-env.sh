#!/bin/bash

# deploy-env.sh - Deployment script for Beauty Booking AWS infrastructure
# Usage: ./scripts/deploy-env.sh <environment> [options]
# Examples: 
#   ./scripts/deploy-env.sh dev
#   ./scripts/deploy-env.sh dev --auto-approve
#   ./scripts/deploy-env.sh dev --plan-only

set -e

# Function to display usage information
function show_usage {
  echo "Usage: $0 <environment> [options]"
  echo "  environment:        Environment to deploy (dev, staging, prod)"
  echo "  --auto-approve:     Apply changes without asking for confirmation"
  echo "  --plan-only:        Create plan without applying"
  echo "  --output-plan:      Save the plan to a file"
  echo "  --help:             Show this help message"
  exit 1
}

# Function to display a header
function header {
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
}

# Function to check if AWS CLI is configured
function check_aws_cli {
  if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI is not properly configured. Please run aws configure first."
    exit 1
  fi
}

# Parse command line arguments
if [ $# -lt 1 ]; then
  show_usage
fi

ENVIRONMENT=$1
shift

AUTO_APPROVE=false
PLAN_ONLY=false
OUTPUT_PLAN=false
PLAN_FILE="terraform-plan-${ENVIRONMENT}.tfplan"

# Parse additional options
while [ "$1" != "" ]; do
  case $1 in
    --auto-approve)
      AUTO_APPROVE=true
      ;;
    --plan-only)
      PLAN_ONLY=true
      ;;
    --output-plan)
      OUTPUT_PLAN=true
      ;;
    --help)
      show_usage
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      ;;
  esac
  shift
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod|local)$ ]]; then
  echo "❌ Invalid environment: $ENVIRONMENT"
  echo "Valid options are: dev, staging, prod, local"
  exit 1
fi

# Navigate to the environment directory
ENV_DIR="environments/${ENVIRONMENT}"
if [ ! -d "$ENV_DIR" ]; then
  echo "❌ Environment directory not found: $ENV_DIR"
  exit 1
fi

cd "$ENV_DIR"

# Show deployment information
header "Beauty Booking AWS Deployment"
echo "Environment: $ENVIRONMENT"
echo "Directory: $ENV_DIR"
echo "Time: $(date)"
echo ""

# Check AWS CLI configuration (skip for local)
if [ "$ENVIRONMENT" != "local" ]; then
  header "Checking AWS Configuration"
  check_aws_cli
  
  AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text)
  AWS_USER=$(aws sts get-caller-identity --query "Arn" --output text)
  
  echo "AWS Account: $AWS_ACCOUNT"
  echo "AWS User: $AWS_USER"
  echo "AWS Region: $(aws configure get region)"
  echo ""
fi

# Initialize Terraform
header "Initializing Terraform"
terraform init -reconfigure
echo ""

# Validate the configuration
header "Validating Terraform Configuration"
terraform validate
echo ""

# Create Terraform plan
header "Creating Terraform Plan"
if [ "$OUTPUT_PLAN" = true ]; then
  terraform plan -out="$PLAN_FILE"
  echo "Plan saved to: $PLAN_FILE"
else
  terraform plan
fi
echo ""

# Apply the changes if not plan-only
if [ "$PLAN_ONLY" = false ]; then
  header "Applying Terraform Changes"
  
  APPLY_COMMAND="terraform apply"
  if [ "$OUTPUT_PLAN" = true ]; then
    APPLY_COMMAND="$APPLY_COMMAND $PLAN_FILE"
  fi
  
  if [ "$AUTO_APPROVE" = true ]; then
    APPLY_COMMAND="$APPLY_COMMAND -auto-approve"
  fi
  
  echo "Running: $APPLY_COMMAND"
  $APPLY_COMMAND
  
  # Show outputs
  header "Deployment Outputs"
  terraform output
fi

header "Deployment Complete"
echo "Environment: $ENVIRONMENT"
echo "Completed at: $(date)"