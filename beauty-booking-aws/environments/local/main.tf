module "network" {
  source = "../../modules/network"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
}

module "database" {
  source = "../../modules/database"

  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.database_subnet_ids
  database_sg_id        = module.network.database_sg_id
  postgres_username     = var.postgres_username
  postgres_password     = var.postgres_password
  postgres_db_name      = var.postgres_db_name
  redis_node_type       = var.redis_node_type
  redis_nodes           = var.redis_nodes
  documentdb_enabled    = false
  opensearch_enabled    = false
  region                = var.region

  depends_on = [
    module.network
  ]
}

module "container" {
  source = "../../modules/container"

  environment         = var.environment
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  public_subnet_ids   = module.network.public_subnet_ids
  ecs_sg_id           = module.network.ecs_sg_id
  alb_sg_id           = module.network.alb_sg_id
  region              = var.region

  api_gateway_desired_count     = 1
  booking_service_desired_count = 1
  scheduling_service_desired_count = 1
  payment_service_desired_count = 1

  depends_on = [
    module.network
  ]
}

module "storage" {
  source = "../../modules/storage"

  environment          = var.environment
  frontend_bucket_name = var.frontend_bucket_name
  uploads_bucket_name  = var.uploads_bucket_name
}

module "identity" {
  source = "../../modules/identity"

  environment = var.environment
  uploads_bucket_arn = module.storage.uploads_bucket_arn

  depends_on = [
    module.storage
  ]
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  environment        = var.environment
  cognito_user_pool  = module.identity.cognito_user_pool_id
  region             = var.region

  depends_on = [
    module.identity
  ]
}

module "messaging" {
  source = "../../modules/messaging"

  environment       = var.environment
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.private_subnet_ids
  kafka_sg_id       = module.network.kafka_sg_id
  kafka_enabled     = false
  region            = var.region

  depends_on = [
    module.network
  ]
}

# Optional module - commented out for basic local setup
# Uncomment if you want to test monitoring features locally
/*
module "monitoring" {
  source = "../../modules/monitoring"

  environment      = var.environment
  vpc_id           = module.network.vpc_id
  ecs_cluster_name = module.container.ecs_cluster_name
  region           = var.region
  prometheus_enabled = false
  xray_enabled     = false

  depends_on = [
    module.container
  ]
}
*/

# Outputs
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


output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_gateway_id
}