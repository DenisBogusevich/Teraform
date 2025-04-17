terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # LocalStack endpoint
  endpoints {
    acm            = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    ecr            = "http://localhost:4566"
    ecs            = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    events         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    kms            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
    cloudfront     = "http://localhost:4566"
    cognitoidentity = "http://localhost:4566"
    cognitoidp     = "http://localhost:4566"
    docdb          = "http://localhost:4566"
    opensearch     = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "beauty-booking"
      ManagedBy   = "terraform"
    }
  }
}