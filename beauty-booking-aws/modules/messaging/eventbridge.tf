resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.environment}-beauty-booking-events"

  tags = {
    Name        = "${var.environment}-beauty-booking-events"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_rule" "booking_created" {
  name        = "${var.environment}-booking-created"
  description = "Capture booking creation events"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["beauty-booking.bookings"]
    detail-type = ["BookingCreated"]
  })

  tags = {
    Name        = "${var.environment}-booking-created"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "booking_created_sqs" {
  rule      = aws_cloudwatch_event_rule.booking_created.name
  target_id = "BookingEventsQueue"
  arn       = aws_sqs_queue.booking_events.arn
  event_bus_name = aws_cloudwatch_event_bus.main.name
}

resource "aws_cloudwatch_event_rule" "booking_updated" {
  name        = "${var.environment}-booking-updated"
  description = "Capture booking update events"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["beauty-booking.bookings"]
    detail-type = ["BookingUpdated"]
  })

  tags = {
    Name        = "${var.environment}-booking-updated"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "booking_updated_sqs" {
  rule      = aws_cloudwatch_event_rule.booking_updated.name
  target_id = "BookingEventsQueue"
  arn       = aws_sqs_queue.booking_events.arn
  event_bus_name = aws_cloudwatch_event_bus.main.name
}

resource "aws_cloudwatch_event_rule" "booking_cancelled" {
  name        = "${var.environment}-booking-cancelled"
  description = "Capture booking cancellation events"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["beauty-booking.bookings"]
    detail-type = ["BookingCancelled"]
  })

  tags = {
    Name        = "${var.environment}-booking-cancelled"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "booking_cancelled_sqs" {
  rule      = aws_cloudwatch_event_rule.booking_cancelled.name
  target_id = "BookingEventsQueue"
  arn       = aws_sqs_queue.booking_events.arn
  event_bus_name = aws_cloudwatch_event_bus.main.name
}

resource "aws_cloudwatch_event_rule" "payment_processed" {
  name        = "${var.environment}-payment-processed"
  description = "Capture payment processing events"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["beauty-booking.payments"]
    detail-type = ["PaymentProcessed"]
  })

  tags = {
    Name        = "${var.environment}-payment-processed"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "payment_processed_sqs" {
  rule      = aws_cloudwatch_event_rule.payment_processed.name
  target_id = "PaymentEventsQueue"
  arn       = aws_sqs_queue.payment_events.arn
  event_bus_name = aws_cloudwatch_event_bus.main.name
}

resource "aws_cloudwatch_event_rule" "notification_event" {
  name        = "${var.environment}-notification-event"
  description = "Capture notification events"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["beauty-booking.notifications"]
    detail-type = ["SendNotification"]
  })

  tags = {
    Name        = "${var.environment}-notification-event"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "notification_event_sqs" {
  rule      = aws_cloudwatch_event_rule.notification_event.name
  target_id = "NotificationEventsQueue"
  arn       = aws_sqs_queue.notification_events.arn
  event_bus_name = aws_cloudwatch_event_bus.main.name
}

# IAM policy for SQS queues to receive events from EventBridge
resource "aws_sqs_queue_policy" "eventbridge_to_sqs" {
  for_each = {
    booking      = aws_sqs_queue.booking_events.id
    notification = aws_sqs_queue.notification_events.id
    payment      = aws_sqs_queue.payment_events.id
  }

  queue_url = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid       = "AllowEventBridgeToSendMessage"
        Effect    = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = each.value == aws_sqs_queue.booking_events.id ? aws_sqs_queue.booking_events.arn : (
          each.value == aws_sqs_queue.notification_events.id ? aws_sqs_queue.notification_events.arn :
          aws_sqs_queue.payment_events.arn)
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_bus.main.arn
          }
        }
      }
    ]
  })
}