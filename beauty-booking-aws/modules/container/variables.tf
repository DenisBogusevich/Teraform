variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS services"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID for Application Load Balancer"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
  default     = ""
}

variable "api_gateway_desired_count" {
  description = "Desired count of API Gateway tasks"
  type        = number
  default     = 1
}

variable "booking_service_desired_count" {
  description = "Desired count of booking service tasks"
  type        = number
  default     = 1
}

variable "scheduling_service_desired_count" {
  description = "Desired count of scheduling service tasks"
  type        = number
  default     = 1
}

variable "payment_service_desired_count" {
  description = "Desired count of payment service tasks"
  type        = number
  default     = 1
}