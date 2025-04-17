# For modules/monitoring/cloudwatch.tf

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-beauty-booking-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "ECS Cluster CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "ECS Cluster Memory Utilization"
        }
      }
    ]
  })
}

# SNS Topic for alarms
resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-beauty-booking-alarms"

  tags = {
    Name        = "${var.environment}-beauty-booking-alarms"
    Environment = var.environment
  }
}

# Add email subscription if alarm_email is provided
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}