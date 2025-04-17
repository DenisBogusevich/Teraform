#!/bin/bash

# Robust setup script for LocalStack environment

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Parse arguments
DESTROY=false
CLEAN=false
DEBUG=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --destroy)
      DESTROY=true
      shift
      ;;
    --clean)
      CLEAN=true
      shift
      ;;
    --debug)
      DEBUG=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--destroy] [--clean] [--debug]"
      exit 1
      ;;
  esac
done

# Function to display header
function header {
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
}

# Function to check if LocalStack is ready
check_localstack_ready() {
  # First check if the container is running
  if ! docker ps | grep -q beauty-booking-localstack; then
     echo "LocalStack container is not running!" >&2
     return 1
   fi

  # Check the general health endpoint
  HEALTH_OUTPUT=$(docker exec beauty-booking-localstack curl -s http://localhost:4566/_localstack/health)
  
  if ! echo "$HEALTH_OUTPUT" | grep -q "\"ready\": true"; then
    return 1
  fi
  
  # Check if S3 service is running
  if ! echo "$HEALTH_OUTPUT" | grep -q "\"s3\": \"running\""; then
    return 1
  fi
  
  return 0
}

# Stop and remove containers if destroy flag is set
if [ "$DESTROY" = true ]; then
  header "Stopping and removing containers"
  docker-compose down -v
  echo "✅ Containers stopped and removed"
  echo "Run the script without --destroy to set up the environment again."
  exit 0
fi

# Clean up existing resources if clean flag is set
if [ "$CLEAN" = true ]; then
  header "Cleaning up existing LocalStack resources"
  
  echo "Stopping any running containers..."
  docker-compose down 2>/dev/null || true
  
  echo "Removing Docker volumes..."
  docker volume rm beauty-booking-aws_localstack_tmp 2>/dev/null || true
  docker volume rm beauty-booking-aws_postgres_data 2>/dev/null || true
  
  echo "✅ Cleanup completed"
fi

header "Starting LocalStack and supporting services"

# First make sure containers are down
docker-compose down 2>/dev/null || true

# Start LocalStack with debug if requested
if [ "$DEBUG" = true ]; then
  DEBUG=1 docker-compose up -d
else
  docker-compose up -d
fi

# Check for container startup
echo "Checking if containers started properly..."
sleep 5

if ! docker ps | grep -q beauty-booking-localstack; then
  echo "❌ LocalStack container failed to start!"
  docker-compose logs
  exit 1
fi

# Wait for LocalStack to be ready
header "Waiting for LocalStack to be ready"
ATTEMPTS=0
MAX_ATTEMPTS=40  # Increased max attempts for more patience

#until check_localstack_ready; do
 # ATTEMPTS=$((ATTEMPTS + 1))
  #if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
   # echo "❌ LocalStack failed to start properly after $MAX_ATTEMPTS attempts"
    #echo "Checking LocalStack logs for errors:"
    #docker logs beauty-booking-localstack | tail -n 50
    #exit 1
  #fi
  
  #echo "Waiting for LocalStack to be ready... (attempt $ATTEMPTS/$MAX_ATTEMPTS)"
 # sleep 5
#done

echo "✅ LocalStack is ready and S3 service is running!"

if [ "$DEBUG" = true ]; then
  echo "LocalStack health status:"
  docker exec beauty-booking-localstack curl -s http://localhost:4566/_localstack/health
fi

# Create required buckets and resources in LocalStack
header "Creating required resources in LocalStack"
echo "Creating S3 buckets..."

# Set AWS CLI environment variables for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Function to create resources with error handling
create_resource() {
  CMD=$1
  RESOURCE_TYPE=$2
  RESOURCE_NAME=$3
  
  echo "Creating $RESOURCE_TYPE: $RESOURCE_NAME"
  if $CMD; then
    echo "  ✓ Success"
  else
    echo "  ⚠ Resource may already exist or error occurred (continuing)"
  fi
}

# Create S3 buckets
create_resource "aws --endpoint-url=http://localhost:4566 s3 mb s3://beauty-booking-frontend-local" "S3 bucket" "beauty-booking-frontend-local"
create_resource "aws --endpoint-url=http://localhost:4566 s3 mb s3://beauty-booking-uploads-local" "S3 bucket" "beauty-booking-uploads-local"
create_resource "aws --endpoint-url=http://localhost:4566 s3 mb s3://beauty-booking-terraform-state-local" "S3 bucket" "beauty-booking-terraform-state-local"

# Set up DynamoDB table for Terraform state locking
create_resource "aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name beauty-booking-terraform-locks-local \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST" "DynamoDB table" "beauty-booking-terraform-locks-local"

echo "✅ LocalStack resources created successfully"

# Validate AWS CLI can connect to LocalStack
header "Validating LocalStack Connection"
if aws --endpoint-url=http://localhost:4566 s3 ls > /dev/null; then
  echo "✅ Successfully connected to LocalStack S3"
else
  echo "❌ Failed to connect to LocalStack"
  exit 1
fi

# Create the Lambda functions directory if it doesn't exist
mkdir -p modules/api-gateway/lambda-functions

# Prepare Lambda authorizer code
echo "Preparing Lambda authorizer..."
cat > modules/api-gateway/lambda-functions/index.js << 'EOF'
// Simple API Gateway Lambda Authorizer for LocalStack
exports.handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // For local development, we'll allow all requests
  const userId = 'user123';
  return {
    principalId: userId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn || '*'
        }
      ]
    },
    context: {
      userId: userId,
      environment: 'local'
    }
  };
};
EOF

# Create zip file for Lambda
(cd modules/api-gateway/lambda-functions && zip -r authorizer.zip index.js) >/dev/null 2>&1

# Move to the local environment directory
header "Deploying Terraform Infrastructure"
cd environments/local

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -reconfigure

# Apply Terraform configuration with auto-approve
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Display terraform outputs
header "Deployment Outputs"
terraform output

header "LocalStack Setup Complete"
echo "Beauty Booking infrastructure is now running locally"
echo ""
echo "Useful commands:"
echo "  docker-compose ps                     # List running containers"
echo "  docker-compose logs localstack        # View LocalStack logs"
echo "  aws --endpoint-url=http://localhost:4566 s3 ls   # List S3 buckets"
echo "  ./robust-setup-local.sh --clean      # Clean up and restart"
echo "  ./robust-setup-local.sh --destroy    # Tear down the environment"
echo "  ./robust-setup-local.sh --debug      # Start with additional debugging"