resource "aws_msk_cluster" "kafka" {
  count                  = var.kafka_enabled ? 1 : 0
  cluster_name           = "${var.environment}-beauty-booking-kafka"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_broker_count

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    client_subnets  = var.subnet_ids
    security_groups = [var.kafka_sg_id]

    storage_info {
      ebs_storage_info {
        volume_size = 20
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka[0].arn
    revision = aws_msk_configuration.kafka[0].latest_revision
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka[0].name
      }
    }
  }

  tags = {
    Name        = "${var.environment}-beauty-booking-kafka"
    Environment = var.environment
  }
}

resource "aws_msk_configuration" "kafka" {
  count          = var.kafka_enabled ? 1 : 0
  name           = "${var.environment}-beauty-booking-kafka-config"
  kafka_versions = [var.kafka_version]

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
delete.topic.enable=true
log.retention.hours=168
num.partitions=3
default.replication.factor=2
min.insync.replicas=2
PROPERTIES
}

resource "aws_cloudwatch_log_group" "kafka" {
  count             = var.kafka_enabled ? 1 : 0
  name              = "/aws/msk/${var.environment}-beauty-booking-kafka"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-kafka-logs"
    Environment = var.environment
  }
}