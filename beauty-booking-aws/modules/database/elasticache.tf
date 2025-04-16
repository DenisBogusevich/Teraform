resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.environment}-redis"
  description                = "Redis cache for the beauty booking application"
  node_type                  = var.redis_node_type
  port                       = 6379
  parameter_group_name       = "default.redis6.x"
  automatic_failover_enabled = var.environment == "prod" ? true : false
  num_cache_clusters         = var.redis_nodes
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [var.database_sg_id]

  tags = {
    Name = "${var.environment}-redis"
  }
}