environment = "dev"
region      = "us-east-1"

# Network
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
database_subnets   = ["10.0.201.0/24", "10.0.202.0/24"]

# Database
postgres_username    = "dbadmin"
postgres_password    = "YourSecurePasswordHere"  # Change this and use AWS Secrets Manager in production
postgres_db_name     = "beauty_booking"
redis_node_type      = "cache.t3.small"
redis_nodes          = 1
documentdb_enabled   = false
opensearch_enabled   = false

# Container
booking_service_desired_count    = 1
scheduling_service_desired_count = 1
payment_service_desired_count    = 1

# Storage
frontend_bucket_name = "beauty-booking-frontend-dev"
uploads_bucket_name  = "beauty-booking-uploads-dev"

# Messaging
kafka_enabled = false

# Monitoring
alarm_email = "alerts@example.com"