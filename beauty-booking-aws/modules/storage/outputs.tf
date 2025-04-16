output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend assets"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_bucket_arn" {
  description = "ARN of the S3 bucket for frontend assets"
  value       = aws_s3_bucket.frontend.arn
}

output "uploads_bucket_name" {
  description = "Name of the S3 bucket for user uploads"
  value       = aws_s3_bucket.uploads.bucket
}

output "uploads_bucket_arn" {
  description = "ARN of the S3 bucket for user uploads"
  value       = aws_s3_bucket.uploads.arn
}

output "frontend_website_endpoint" {
  description = "Website endpoint for the frontend bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}