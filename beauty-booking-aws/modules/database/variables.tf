variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the database"
  type        = list(string)
}

variable "database_sg_id" {
  description = "Security group ID for the database"
  type        = string
}

# PostgreSQL
variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "postgres_db_name" {
  description = "PostgreSQL database name"
  type        = string
}

# Redis
variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.small"
}

variable "redis_nodes" {
  description = "Number of ElastiCache Redis nodes"
  type        = number
  default     = 1
}

# DocumentDB
variable "documentdb_enabled" {
  description = "Whether to provision DocumentDB"
  type        = bool
  default     = false
}

variable "documentdb_username" {
  description = "DocumentDB master username"
  type        = string
  default     = "docdbadmin"
  sensitive   = true
}

variable "documentdb_password" {
  description = "DocumentDB master password"
  type        = string
  default     = ""
  sensitive   = true
}

# OpenSearch
variable "opensearch_enabled" {
  description = "Whether to provision OpenSearch"
  type        = bool
  default     = false
}

variable "opensearch_instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_master_user_name" {
  description = "OpenSearch master user name"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "opensearch_master_user_password" {
  description = "OpenSearch master user password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "opensearch_allowed_ips" {
  description = "List of IP addresses allowed to access OpenSearch"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Not recommended for production
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}