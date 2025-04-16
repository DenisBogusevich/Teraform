variable "environment" {
  description = "Environment name"
  type        = string
  default     = "local"
}

variable "region" {
  description = "AWS region (used for LocalStack)"
  type        = string
  default     = "us-east-1"
}

# Network variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24"]
}

# Database variables
variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "localuser"
}

variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  default     = "localpassword"
}

variable "postgres_db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "beauty_booking_local"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_nodes" {
  description = "Number of ElastiCache Redis nodes"
  type        = number
  default     = 1
}

# Storage variables
variable "frontend_bucket_name" {
  description = "S3 bucket name for frontend assets"
  type        = string
  default     = "beauty-booking-frontend-local"
}

variable "uploads_bucket_name" {
  description = "S3 bucket name for user uploads"
  type        = string
  default     = "beauty-booking-uploads-local"
}