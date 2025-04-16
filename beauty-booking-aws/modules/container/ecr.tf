resource "aws_ecr_repository" "api_gateway" {
  name                 = "${var.environment}-api-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-api-gateway"
  }
}

resource "aws_ecr_repository" "booking_service" {
  name                 = "${var.environment}-booking-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-booking-service"
  }
}

resource "aws_ecr_repository" "scheduling_service" {
  name                 = "${var.environment}-scheduling-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-scheduling-service"
  }
}

resource "aws_ecr_repository" "payment_service" {
  name                 = "${var.environment}-payment-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-payment-service"
  }
}

resource "aws_ecr_lifecycle_policy" "common" {
  for_each   = {
    api_gateway       = aws_ecr_repository.api_gateway.name
    booking_service   = aws_ecr_repository.booking_service.name
    scheduling_service = aws_ecr_repository.scheduling_service.name
    payment_service   = aws_ecr_repository.payment_service.name
  }

  repository = each.value

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}