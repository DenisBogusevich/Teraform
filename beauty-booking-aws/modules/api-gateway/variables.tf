variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cognito_user_pool" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Custom domain name for API Gateway"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for custom domain"
  type        = string
  default     = ""
}