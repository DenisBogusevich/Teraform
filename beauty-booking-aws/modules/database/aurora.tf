resource "aws_rds_cluster" "postgres" {
  cluster_identifier      = "${var.environment}-aurora-postgres"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "13.6"
  database_name           = var.postgres_db_name
  master_username         = var.postgres_username
  master_password         = var.postgres_password
  backup_retention_period = var.environment == "prod" ? 7 : 1
  preferred_backup_window = "03:00-04:00"
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [var.database_sg_id]
  skip_final_snapshot     = var.environment != "prod"

  tags = {
    Name = "${var.environment}-aurora-postgres"
  }
}

resource "aws_rds_cluster_instance" "postgres" {
  count               = var.environment == "prod" ? 2 : 1
  identifier          = "${var.environment}-aurora-postgres-${count.index}"
  cluster_identifier  = aws_rds_cluster.postgres.id
  instance_class      = var.environment == "prod" ? "db.r5.large" : "db.t4g.medium"
  engine              = "aurora-postgresql"
  engine_version      = "13.6"
  db_subnet_group_name = aws_db_subnet_group.aurora.name

  tags = {
    Name = "${var.environment}-aurora-postgres-${count.index}"
  }
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.environment}-aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.environment}-aurora-subnet-group"
  }
}