output "cost_anomaly_monitor_arn" {
  description = "ARN of the cost anomaly monitor."
  value       = aws_ce_anomaly_monitor.main.arn
}
