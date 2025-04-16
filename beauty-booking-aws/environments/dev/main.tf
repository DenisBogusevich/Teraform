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
  documentdb_enabled    = var.documentdb_enabled
  opensearch_enabled    = var.opensearch_enabled

  depends_on = [
    module.network
  ]
}

module "container" {
  source = "../../modules/container"

  environment         = var.environment
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  ecs_sg_id           = module.network.ecs_sg_id

  booking_service_desired_count     = var.booking_service_desired_count
  scheduling_service_desired_count  = var.scheduling_service_desired_count
  payment_service_desired_count     = var.payment_service_desired_count

  depends_on = [
    module.network
  ]
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  environment        = var.environment
  cognito_user_pool  = module.identity.cognito_user_pool_id

  depends_on = [
    module.identity
  ]
}

module "identity" {
  source = "../../modules/identity"

  environment = var.environment
}

module "storage" {
  source = "../../modules/storage"

  environment          = var.environment
  frontend_bucket_name = var.frontend_bucket_name
  uploads_bucket_name  = var.uploads_bucket_name
}

module "messaging" {
  source = "../../modules/messaging"

  environment       = var.environment
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.private_subnet_ids
  kafka_sg_id       = module.network.kafka_sg_id
  kafka_enabled     = var.kafka_enabled

  depends_on = [
    module.network
  ]
}

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.network.vpc_id

  depends_on = [
    module.network
  ]
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment      = var.environment
  vpc_id           = module.network.vpc_id
  alarm_email      = var.alarm_email
  ecs_cluster_name = module.container.ecs_cluster_name

  depends_on = [
    module.container
  ]
}