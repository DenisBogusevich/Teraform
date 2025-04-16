resource "aws_sqs_queue" "booking_events" {
  name                      = "${var.environment}-booking-events"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.booking_events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name        = "${var.environment}-booking-events"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "booking_events_dlq" {
  name                      = "${var.environment}-booking-events-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.environment}-booking-events-dlq"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "notification_events" {
  name                      = "${var.environment}-notification-events"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name        = "${var.environment}-notification-events"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "notification_events_dlq" {
  name                      = "${var.environment}-notification-events-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.environment}-notification-events-dlq"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "payment_events" {
  name                      = "${var.environment}-payment-events"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name        = "${var.environment}-payment-events"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "payment_events_dlq" {
  name                      = "${var.environment}-payment-events-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.environment}-payment-events-dlq"
    Environment = var.environment
  }
}