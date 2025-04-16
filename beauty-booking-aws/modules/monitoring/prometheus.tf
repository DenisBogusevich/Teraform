resource "aws_prometheus_workspace" "prometheus" {
  count = var.prometheus_enabled ? 1 : 0
  alias = "${var.environment}-beauty-booking-prometheus"

  tags = {
    Name        = "${var.environment}-beauty-booking-prometheus"
    Environment = var.environment
  }
}

resource "aws_prometheus_rule_group_namespace" "ecs_rules" {
  count = var.prometheus_enabled ? 1 : 0
  name  = "${var.environment}-ecs-rules"

  workspace_id = aws_prometheus_workspace.prometheus[0].id

  data = <<EOF
groups:
  - name: ecs_alerts
    rules:
      - alert: HighCPUUsage
        expr: avg by(task_definition_family) (rate(container_cpu_usage_seconds_total[5m])) * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High CPU usage on ECS task (> 80%)
          description: "ECS task {{ $labels.task_definition_family }} CPU usage is high ({{ $value }}%)"

      - alert: HighMemoryUsage
        expr: avg by(task_definition_family) (container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High memory usage on ECS task (> 80%)
          description: "ECS task {{ $labels.task_definition_family }} memory usage is high ({{ $value }}%)"

      - alert: TaskRestart
        expr: changes(container_last_seen{container_label_com_amazonaws_ecs_task_definition_family=~".+"}[15m]) > 3
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: ECS task restarting frequently
          description: "ECS task {{ $labels.task_definition_family }} has restarted {{ $value }} times in the last 15 minutes"
EOF
}

resource "aws_prometheus_rule_group_namespace" "api_rules" {
  count = var.prometheus_enabled ? 1 : 0
  name  = "${var.environment}-api-rules"

  workspace_id = aws_prometheus_workspace.prometheus[0].id

  data = <<EOF
groups:
  - name: api_alerts
    rules:
      - alert: HighAPILatency
        expr: histogram_quantile(0.95, rate(http_request_duration_ms_bucket[5m])) > 1000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High API latency (> 1s)
          description: "95th percentile of request durations is {{ $value }}ms"

      - alert: High5xxRate
        expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100 > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High 5xx error rate (> 5%)
          description: "5xx error rate is {{ $value }}%"

      - alert: High4xxRate
        expr: sum(rate(http_requests_total{status=~"4.."}[5m])) / sum(rate(http_requests_total[5m])) * 100 > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High 4xx error rate (> 10%)
          description: "4xx error rate is {{ $value }}%"
EOF
}

resource "aws_iam_role" "prometheus_ingest" {
  count = var.prometheus_enabled ? 1 : 0
  name  = "${var.environment}-prometheus-ingest-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-prometheus-ingest-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "prometheus_ingest" {
  count       = var.prometheus_enabled ? 1 : 0
  name        = "${var.environment}-prometheus-ingest-policy"
  description = "Policy for Prometheus remote write ingest"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.prometheus[0].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_ingest" {
  count      = var.prometheus_enabled ? 1 : 0
  role       = aws_iam_role.prometheus_ingest[0].name
  policy_arn = aws_iam_policy.prometheus_ingest[0].arn
}