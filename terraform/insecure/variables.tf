variable "aws_region" {
  description = "AWS region used for the cloud security lab"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify resources created by this project"
  type        = string
  default     = "aws-cloud-security-posture-remediation"
}

variable "environment" {
  description = "Environment classification"
  type        = string
  default     = "insecure-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.10.1.0/24"
}
