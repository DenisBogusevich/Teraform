variable "environment" {
  description = "Environment name"
  type        = string
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for frontend assets"
  type        = string
}

variable "uploads_bucket_name" {
  description = "S3 bucket name for user uploads"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for CloudFront"
  type        = string
  default     = ""
}