resource "aws_sns_topic" "booking_notifications" {
  name = "${var.environment}-booking-notifications"

  tags = {
    Name        = "${var.environment}-booking-notifications"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "booking_notifications_sqs" {
  topic_arn = aws_sns_topic.booking_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.notification_events.arn
}

resource "aws_sns_topic_policy" "booking_notifications_policy" {
  arn = aws_sns_topic.booking_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid       = "__default_statement_ID"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ]
        Resource  = aws_sns_topic.booking_notifications.arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic" "system_alerts" {
  name = "${var.environment}-system-alerts"

  tags = {
    Name        = "${var.environment}-system-alerts"
    Environment = var.environment
  }
}

resource "aws_sns_topic_policy" "system_alerts_policy" {
  arn = aws_sns_topic.system_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid       = "__default_statement_ID"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ]
        Resource  = aws_sns_topic.system_alerts.arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Example email subscription for system alerts
resource "aws_sns_topic_subscription" "system_alerts_email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.system_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# SQS policy to allow SNS to send messages
resource "aws_sqs_queue_policy" "notification_events_policy" {
  queue_url = aws_sqs_queue.notification_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid       = "AllowSNSToSendMessage"
        Effect    = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.notification_events.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.booking_notifications.arn
          }
        }
      }
    ]
  })
}

# Current identity for policy
data "aws_caller_identity" "current" {}