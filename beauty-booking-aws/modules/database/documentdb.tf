resource "aws_docdb_subnet_group" "documentdb" {
  count      = var.documentdb_enabled ? 1 : 0
  name       = "${var.environment}-docdb-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.environment}-docdb-subnet-group"
  }
}

resource "aws_docdb_cluster" "documentdb" {
  count                   = var.documentdb_enabled ? 1 : 0
  cluster_identifier      = "${var.environment}-documentdb"
  engine                  = "docdb"
  master_username         = var.documentdb_username
  master_password         = var.documentdb_password
  backup_retention_period = var.environment == "prod" ? 7 : 1
  preferred_backup_window = "04:00-05:00"
  skip_final_snapshot     = var.environment != "prod"
  db_subnet_group_name    = aws_docdb_subnet_group.documentdb[0].name
  vpc_security_group_ids  = [var.database_sg_id]

  tags = {
    Name = "${var.environment}-documentdb"
  }
}

resource "aws_docdb_cluster_instance" "documentdb" {
  count              = var.documentdb_enabled ? (var.environment == "prod" ? 2 : 1) : 0
  identifier         = "${var.environment}-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.documentdb[0].id
  instance_class     = var.environment == "prod" ? "db.r5.large" : "db.t3.medium"

  tags = {
    Name = "${var.environment}-docdb-instance-${count.index}"
  }
}