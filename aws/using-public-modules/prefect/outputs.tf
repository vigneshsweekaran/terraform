
output "prefect_ui_url" {
  description = "The URL for the Prefect UI."
  value       = "http://${aws_lb.prefect.dns_name}"
}

output "prefect_api_url" {
  description = "The URL for the Prefect API."
  value       = "http://${aws_lb.prefect.dns_name}/api"
}
