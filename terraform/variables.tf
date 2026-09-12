variable "aws_region" {
  description = "AWS region for all Terraform resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix used across resources."
  type        = string
  default     = "shophub"
}

variable "environment" {
  description = "Environment name for this deployment."
  type        = string
  default     = "test"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones used by the public subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ec2_ami" {
  description = "Ubuntu AMI ID for the EC2 instances. Replace with a valid AMI in your region."
  type        = string
  default     = "ami-0f8a61b66d1accaee"
}

variable "ec2_instance_type" {
  description = "Low-cost EC2 instance type for test deployments."
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Existing AWS EC2 key pair name used for SSH access."
  type        = string
  default     = "testkey"
}

variable "backend_port" {
  description = "Backend application HTTP port."
  type        = number
  default     = 8000
}

variable "frontend_port" {
  description = "Frontend application HTTP port."
  type        = number
  default     = 5173
}

variable "db_username" {
  description = "Master username for the RDS MySQL instance."
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS MySQL instance."
  type        = string
  default     = "ubuntu123"
  sensitive   = true
}

variable "db_name" {
  description = "Database name for the RDS instance."
  type        = string
  default     = "shophub"
}

variable "db_instance_class" {
  description = "Small RDS instance class for classroom or test workloads."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for the RDS instance in GB."
  type        = number
  default     = 20
}

variable "backend_bucket_name" {
  description = "Unique bucket name for backend-related artifacts."
  type        = string
  default     = "shophub-backend-artifacts"
}
