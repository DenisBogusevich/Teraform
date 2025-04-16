output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.network.database_subnet_ids
}

output "postgres_endpoint" {
  description = "Aurora PostgreSQL cluster endpoint"
  value       = module.database.postgres_endpoint
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.database.redis_endpoint
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.container.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.container.ecs_cluster_arn
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value       = module.container.ecr_repository_urls
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.identity.cognito_user_pool_id
}

output "cognito_app_client_id" {
  description = "ID of the Cognito App Client"
  value       = module.identity.cognito_app_client_id
}

output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend assets"
  value       = module.storage.frontend_bucket_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.storage.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.storage.cloudfront_domain_name
}