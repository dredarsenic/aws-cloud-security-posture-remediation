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

output "secure_instance_id" {
  description = "Instance ID of the hardened EC2 workload"
  value       = aws_instance.secure_web.id
}

output "secure_instance_public_ip" {
  description = "Public IPv4 address of the hardened EC2 workload"
  value       = aws_instance.secure_web.public_ip
}

output "secure_security_group_id" {
  description = "Security group attached to the hardened EC2 workload"
  value       = aws_security_group.secure_web.id
}

output "ssm_instance_role_name" {
  description = "IAM role used by the EC2 workload for Systems Manager"
  value       = aws_iam_role.ec2_ssm.name
}

output "secure_bucket_name" {
  description = "Name of the hardened S3 lab bucket"
  value       = aws_s3_bucket.public_lab.id
}

output "demo_object_url" {
  description = "URL of the harmless demonstration object"
  value       = "https://${aws_s3_bucket.public_lab.bucket}.s3.${var.aws_region}.amazonaws.com/${aws_s3_object.demo_file.key}"
}

output "cloudtrail_name" {
  description = "Name of the customer-managed multi-Region CloudTrail trail"
  value       = aws_cloudtrail.audit.name
}

output "access_analyzer_name" {
  description = "Name of the account-level IAM Access Analyzer"
  value       = aws_accessanalyzer_analyzer.account.analyzer_name
}
