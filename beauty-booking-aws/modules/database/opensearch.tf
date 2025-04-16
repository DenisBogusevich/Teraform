resource "aws_opensearch_domain" "opensearch" {
  count         = var.opensearch_enabled ? 1 : 0
  domain_name   = "${var.environment}-beauty-booking"
  engine_version = "OpenSearch_1.3"

  cluster_config {
    instance_type = var.opensearch_instance_type
    instance_count = var.environment == "prod" ? 3 : 1

    zone_awareness_enabled = var.environment == "prod" ? true : false

    zone_awareness_config {
      availability_zone_count = var.environment == "prod" ? 3 : 2
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.environment == "prod" ? 100 : 20
    volume_type = "gp3"
  }

  vpc_options {
    subnet_ids         = var.environment == "prod" ? [var.subnet_ids[0], var.subnet_ids[1]] : [var.subnet_ids[0]]
    security_group_ids = [var.database_sg_id]
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.opensearch_master_user_name
      master_user_password = var.opensearch_master_user_password
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "es:*"
        Resource = "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.environment}-beauty-booking/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.opensearch_allowed_ips
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-opensearch"
    Environment = var.environment
  }
}

# Get current account ID
data "aws_caller_identity" "current" {}