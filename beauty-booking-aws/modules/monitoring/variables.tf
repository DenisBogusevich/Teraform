variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "alarm_email" {
  description = "Email address to send CloudWatch alarms"
  type        = string
  default     = ""
}

variable "prometheus_enabled" {
  description = "Whether to enable Amazon Managed Prometheus"
  type        = bool
  default     = false
}

variable "xray_enabled" {
  description = "Whether to enable AWS X-Ray tracing"
  type        = bool
  default     = false
}