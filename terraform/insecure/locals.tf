locals {
  name_prefix = "cloudsec-lab"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Cloud Security Assessment Lab"
    Owner       = "dredarsenic"
  }
}
