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

  booking_service_desired_count     = 1
  scheduling_service_desired_count  = 1
  payment_service_desired_count     = 1

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

# Minimal identity setup for local
module "identity" {
  source = "../../modules/identity"

  environment = var.environment
}