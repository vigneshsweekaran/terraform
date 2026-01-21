output "load_balancer_ip" {
  description = "External Load Balancer IP Address"
  value       = var.enable_load_balancer ? google_compute_address.lb_ip[0].address : null
}

output "forwarding_rule_name" {
  description = "Forwarding Rule Name"
  value       = var.enable_load_balancer ? google_compute_forwarding_rule.lb_forwarding_rule[0].name : null
}
