output "booking_events_queue_url" {
  description = "URL of the booking events SQS queue"
  value       = aws_sqs_queue.booking_events.id
}

output "booking_events_queue_arn" {
  description = "ARN of the booking events SQS queue"
  value       = aws_sqs_queue.booking_events.arn
}

output "notification_events_queue_url" {
  description = "URL of the notification events SQS queue"
  value       = aws_sqs_queue.notification_events.id
}

output "notification_events_queue_arn" {
  description = "ARN of the notification events SQS queue"
  value       = aws_sqs_queue.notification_events.arn
}

output "payment_events_queue_url" {
  description = "URL of the payment events SQS queue"
  value       = aws_sqs_queue.payment_events.id
}

output "payment_events_queue_arn" {
  description = "ARN of the payment events SQS queue"
  value       = aws_sqs_queue.payment_events.arn
}

output "booking_notifications_topic_arn" {
  description = "ARN of the booking notifications SNS topic"
  value       = aws_sns_topic.booking_notifications.arn
}

output "system_alerts_topic_arn" {
  description = "ARN of the system alerts SNS topic"
  value       = aws_sns_topic.system_alerts.arn
}

output "event_bus_arn" {
  description = "ARN of the EventBridge event bus"
  value       = aws_cloudwatch_event_bus.main.arn
}

output "event_bus_name" {
  description = "Name of the EventBridge event bus"
  value       = aws_cloudwatch_event_bus.main.name
}

output "kafka_bootstrap_brokers" {
  description = "Kafka bootstrap brokers"
  value       = var.kafka_enabled ? aws_msk_cluster.kafka[0].bootstrap_brokers : null
}

output "kafka_zookeeper_connect_string" {
  description = "Kafka ZooKeeper connection string"
  value       = var.kafka_enabled ? aws_msk_cluster.kafka[0].zookeeper_connect_string : null
}