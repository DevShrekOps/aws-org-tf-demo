output "sec_guardduty_detector_id" {
  description = "ID of the regional GuardDuty Detector in the security account."
  value       = aws_guardduty_detector.sec.id
}
