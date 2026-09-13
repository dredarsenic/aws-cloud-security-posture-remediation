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

output "insecure_instance_id" {
  description = "Instance ID of the intentionally insecure EC2 workload"
  value       = aws_instance.insecure_web.id
}

output "insecure_instance_public_ip" {
  description = "Public IPv4 address of the intentionally insecure EC2 workload"
  value       = aws_instance.insecure_web.public_ip
}

output "insecure_security_group_id" {
  description = "Security group attached to the intentionally insecure EC2 workload"
  value       = aws_security_group.insecure_web.id
}

output "public_bucket_name" {
  description = "Name of the intentionally public S3 lab bucket"
  value       = aws_s3_bucket.public_lab.id
}

output "public_demo_object_url" {
  description = "URL of the harmless demonstration object"
  value       = "https://${aws_s3_bucket.public_lab.bucket}.s3.${var.aws_region}.amazonaws.com/${aws_s3_object.demo_file.key}"
}
