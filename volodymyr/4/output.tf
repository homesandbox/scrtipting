output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
  description = "The DNS name of the ALB."
}
