output "lb_domain_name" {
  value = aws_lb.nginx.dns_name
}