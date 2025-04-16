output "postgres_endpoint" {
  description = "The endpoint of the PostgreSQL cluster"
  value       = aws_rds_cluster.postgres.endpoint
}

output "postgres_reader_endpoint" {
  description = "The reader endpoint of the PostgreSQL cluster"
  value       = aws_rds_cluster.postgres.reader_endpoint
}

output "postgres_database_name" {
  description = "The database name"
  value       = aws_rds_cluster.postgres.database_name
}

output "redis_endpoint" {
  description = "The primary endpoint of the Redis cluster"
  value       = "${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
}

output "redis_reader_endpoint" {
  description = "The reader endpoint of the Redis cluster"
  value       = "${aws_elasticache_replication_group.redis.reader_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
}

output "documentdb_endpoint" {
  description = "The endpoint of the DocumentDB cluster"
  value       = var.documentdb_enabled ? aws_docdb_cluster.documentdb[0].endpoint : null
}

output "documentdb_reader_endpoint" {
  description = "The reader endpoint of the DocumentDB cluster"
  value       = var.documentdb_enabled ? aws_docdb_cluster.documentdb[0].reader_endpoint : null
}

output "opensearch_endpoint" {
  description = "The endpoint of the OpenSearch domain"
  value       = var.opensearch_enabled ? aws_opensearch_domain.opensearch[0].endpoint : null
}