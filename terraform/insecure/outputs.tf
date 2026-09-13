output "aws_region" {
  description = "AWS region used by the lab"
  value       = var.aws_region
}

output "environment" {
  description = "Lab environment classification"
  value       = var.environment
}

output "vpc_id" {
  description = "ID of the lab VPC"
  value       = aws_vpc.lab.id
}

output "public_subnet_id" {
  description = "ID of the public lab subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the lab Internet Gateway"
  value       = aws_internet_gateway.lab.id
}

output "availability_zone" {
  description = "Availability Zone selected for the lab"
  value       = aws_subnet.public.availability_zone
}
