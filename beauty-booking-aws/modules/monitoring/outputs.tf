output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "alarm_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.arn
}

output "log_groups" {
  description = "Map of Log Group names"
  value = {
    api_gateway       = aws_cloudwatch_log_group.api_gateway.name
    booking_service   = aws_cloudwatch_log_group.ecs_booking_service.name
    scheduling_service = aws_cloudwatch_log_group.ecs_scheduling_service.name
    payment_service   = aws_cloudwatch_log_group.ecs_payment_service.name
    api_gateway_service = aws_cloudwatch_log_group.ecs_api_gateway.name
  }
}

output "prometheus_workspace_endpoint" {
  description = "Endpoint of the Amazon Managed Prometheus workspace"
  value       = var.prometheus_enabled ? aws_prometheus_workspace.prometheus[0].prometheus_endpoint : null
}