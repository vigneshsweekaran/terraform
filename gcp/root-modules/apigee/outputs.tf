output "apigee_org_id" {
  description = "Apigee Organization ID"
  value       = module.apigee.org_id
}

output "apigee_instance_id" {
  description = "Apigee Instance ID"
  value       = module.apigee.instance_id
}

output "vpc_id" {
  description = "VPC Network ID"
  value       = module.vpc.vpc_id
}

output "load_balancer_ip" {
  description = "External Load Balancer IP Address"
  value       = module.lb.load_balancer_ip
}

output "test_external_url" {
  description = "Test URL for external access"
  value       = module.lb.load_balancer_ip != null ? "https://${var.apigee_hostname}" : null
}
