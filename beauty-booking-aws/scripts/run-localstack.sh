#!/bin/bash

# This script starts LocalStack with Docker for local development

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

echo "Starting LocalStack..."

# Create a docker-compose.yml file for LocalStack
cat > docker-compose.yml << EOF
version: '3.8'

services:
  localstack:
    container_name: beauty-booking-localstack
    image: localstack/localstack:latest
    ports:
      - "4566:4566"            # LocalStack Gateway
      - "4510-4559:4510-4559"  # External services port range
    environment:
      - DEBUG=1
      - DOCKER_HOST=unix:///var/run/docker.sock
      - HOSTNAME_EXTERNAL=localhost
      - SERVICES=s3,dynamodb,iam,lambda,sqs,sns,ec2,apigateway,ecs
      - DEFAULT_REGION=us-east-1
      - AWS_DEFAULT_REGION=us-east-1
      - AWS_ACCESS_KEY_ID=mock-access-key
      - AWS_SECRET_ACCESS_KEY=mock-secret-key
    volumes:
      - "${TMPDIR:-/tmp}/localstack:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks:
      - beauty-booking-local

networks:
  beauty-booking-local:
    driver: bridge
EOF

# Start LocalStack using docker-compose
docker-compose up -d

echo "LocalStack is running. You can access the services at http://localhost:4566"
echo "To stop LocalStack, run: docker-compose down"
echo ""
echo "AWS CLI is configured with the following credentials:"
echo "- Region: us-east-1"
echo "- Access Key: mock-access-key"
echo "- Secret Key: mock-secret-key"
echo ""
echo "Example AWS CLI command with LocalStack:"
echo "aws --endpoint-url=http://localhost:4566 s3 ls"
echo ""
echo "To apply Terraform to LocalStack:"
echo "cd environments/local"
echo "terraform init"
echo "terraform apply"