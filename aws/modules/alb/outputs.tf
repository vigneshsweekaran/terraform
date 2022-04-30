output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "arn_suffix" {
  value = aws_lb.main.arn_suffix
}