# For modules/monitoring/logs.tf

# CloudWatch Log Groups for services
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.environment}-beauty-booking-api"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-api-gateway-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs_api_gateway" {
  name              = "/ecs/${var.environment}/api-gateway"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-ecs-api-gateway-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs_booking_service" {
  name              = "/ecs/${var.environment}/booking-service"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-ecs-booking-service-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs_scheduling_service" {
  name              = "/ecs/${var.environment}/scheduling-service"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-ecs-scheduling-service-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs_payment_service" {
  name              = "/ecs/${var.environment}/payment-service"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-ecs-payment-service-logs"
    Environment = var.environment
  }
}