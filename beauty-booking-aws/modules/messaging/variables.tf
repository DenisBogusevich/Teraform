variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "kafka_sg_id" {
  description = "Security group ID for Kafka"
  type        = string
}

variable "kafka_enabled" {
  description = "Whether to provision MSK Kafka"
  type        = bool
  default     = false
}

variable "kafka_instance_type" {
  description = "Kafka broker instance type"
  type        = string
  default     = "kafka.t3.small"
}

variable "kafka_broker_count" {
  description = "Number of Kafka brokers"
  type        = number
  default     = 2
}

variable "kafka_version" {
  description = "Kafka version"
  type        = string
  default     = "2.8.1"
}

variable "alert_email" {
  description = "Email address for system alerts"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}