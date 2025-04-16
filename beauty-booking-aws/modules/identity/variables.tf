variable "environment" {
  description = "Environment name"
  type        = string
}

variable "uploads_bucket_arn" {
  description = "ARN of the S3 bucket for user uploads"
  type        = string
  default     = ""
}