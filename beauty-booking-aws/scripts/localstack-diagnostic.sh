#!/bin/bash

# LocalStack Diagnostic Tool
# This script helps diagnose issues with LocalStack in the beauty-booking-aws project

echo "LocalStack Diagnostic Tool"
echo "-------------------------"
echo

# Check if Docker is running
echo "1. Checking Docker..."
if docker info &>/dev/null; then
  echo "✅ Docker is running"
else
  echo "❌ Docker is not running"
  echo "Please start Docker and try again"
  exit 1
fi

# Check if LocalStack container exists
echo 
echo "2. Checking LocalStack container..."
if docker ps | grep -q beauty-booking-localstack; then
  echo "✅ LocalStack container is running"
  CONTAINER_ID=$(docker ps | grep beauty-booking-localstack | awk '{print $1}')
  echo "   Container ID: $CONTAINER_ID"
else
  if docker ps -a | grep -q beauty-booking-localstack; then
    echo "⚠️ LocalStack container exists but is not running"
    CONTAINER_ID=$(docker ps -a | grep beauty-booking-localstack | awk '{print $1}')
    echo "   Container ID: $CONTAINER_ID"
    echo "   Container status:"
    docker inspect $CONTAINER_ID --format='{{ .State.Status }}'
    echo "   Exit code:"
    docker inspect $CONTAINER_ID --format='{{ .State.ExitCode }}'
  else
    echo "❌ LocalStack container does not exist"
    echo "Run ./robust-setup-local.sh to start LocalStack"
    exit 1
  fi
fi

# Check LocalStack logs
echo 
echo "3. Checking LocalStack logs (last 10 lines)..."
docker logs beauty-booking-localstack --tail 10 2>/dev/null || echo "   Cannot retrieve logs"

# Check LocalStack health
echo 
echo "4. Checking LocalStack health..."
if docker ps | grep -q beauty-booking-localstack; then
  HEALTH_OUTPUT=$(docker exec beauty-booking-localstack curl -s http://localhost:4566/_localstack/health 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "   Health endpoint response:"
    echo "$HEALTH_OUTPUT" | grep -E '"ready"|"running"|"starting"|"error"'
    
    # Check if ready
    if echo "$HEALTH_OUTPUT" | grep -q "\"ready\": true"; then
      echo "✅ LocalStack reports it is ready"
    else
      echo "⚠️ LocalStack is not ready yet"
    fi
    
    # Check services
    echo 
    echo "5. Checking required services..."
    for SERVICE in s3 dynamodb lambda apigateway iam; do
      STATUS=$(echo "$HEALTH_OUTPUT" | grep -o "\"$SERVICE\": \"[^\"]*\"")
      if echo "$STATUS" | grep -q "running"; then
        echo "   ✅ $SERVICE: running"
      elif echo "$STATUS" | grep -q "starting"; then
        echo "   ⏳ $SERVICE: starting"
      elif echo "$STATUS" | grep -q "error"; then
        echo "   ❌ $SERVICE: error"
      else
        echo "   ❓ $SERVICE: unknown status"
      fi
    done
  else
    echo "❌ Cannot connect to health endpoint"
  fi
else
  echo "❌ LocalStack container is not running"
fi

# Check AWS CLI connectivity
echo 
echo "6. Testing AWS CLI connectivity to LocalStack..."
if aws --endpoint-url=http://localhost:4566 --region=us-east-1 s3 ls &>/dev/null; then
  echo "✅ AWS CLI can connect to LocalStack S3"
  echo "   S3 buckets:"
  aws --endpoint-url=http://localhost:4566 --region=us-east-1 s3 ls
else
  echo "❌ AWS CLI cannot connect to LocalStack"
  echo "   Make sure LocalStack is running and AWS CLI is installed"
fi

# Check Docker Compose configuration
echo 
echo "7. Checking Docker Compose configuration..."
if docker-compose config &>/dev/null; then
  echo "✅ docker-compose.yml is valid"
else
  echo "❌ docker-compose.yml has errors"
  docker-compose config
fi

# Check Docker volumes
echo 
echo "8. Checking Docker volumes..."
LOCALSTACK_VOLUMES=$(docker volume ls | grep beauty-booking | awk '{print $2}')
if [ -n "$LOCALSTACK_VOLUMES" ]; then
  echo "✅ Found volumes for beauty-booking project:"
  echo "$LOCALSTACK_VOLUMES"
else
  echo "⚠️ No volumes found for beauty-booking project"
fi

# Memory and disk usage
echo 
echo "9. Checking system resources..."
if docker ps | grep -q beauty-booking-localstack; then
  echo "   LocalStack container memory usage:"
  docker stats beauty-booking-localstack --no-stream --format "{{.Container}}: {{.MemUsage}}"
fi

echo
echo "Diagnostic complete! Use this information to troubleshoot your LocalStack setup."
echo "If you continue to have issues, try running: ./robust-setup-local.sh --clean"