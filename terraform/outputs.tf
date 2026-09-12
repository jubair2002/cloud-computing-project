output "vpc_id" {
  description = "VPC ID created for the test deployment."
  value       = aws_vpc.main.id
}

output "backend_ec2_public_ip" {
  description = "Public IP of the backend EC2 host."
  value       = aws_instance.backend.public_ip
}

output "frontend_ec2_public_ip" {
  description = "Public IP of the frontend EC2 host."
  value       = aws_instance.frontend.public_ip
}

output "rds_endpoint" {
  description = "RDS database hostname."
  value       = aws_db_instance.mysql.address
}

output "alb_dns_name" {
  description = "DNS name of the frontend ALB."
  value       = aws_lb.frontend_alb.dns_name
}

