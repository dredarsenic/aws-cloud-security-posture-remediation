# Post-Remediation Validation

This directory summarizes direct validation performed after applying the hardened Terraform configuration.

Raw runtime evidence is retained locally under `evidence/raw/remediation/` and excluded from version control. Published evidence is sanitized to remove AWS account IDs, resource identifiers, public IP addresses, DNS names, and other runtime-specific metadata.

## Validation Results

| Finding | Remediation Validation | Result |
|---|---|---|
| IAM-001 | Privileged lab IAM user removed; EC2 administration moved to Systems Manager role | Remediated |
| S3-001 | Anonymous object request returns HTTP 403; Block Public Access enabled; bucket policy reports non-public | Remediated |
| NET-001 | TCP/22 removed from security group and external SSH connection times out | Remediated |
| LOG-001 | Multi-Region CloudTrail active with global service events and log-file validation | Remediated |
| EC2-001 | EC2 metadata requires IMDSv2 tokens | Remediated |
| EC2-002 | Root EBS volume encrypted; regional EBS encryption-by-default enabled | Remediated |
| DET-001 | IAM Access Analyzer enabled and active | Partially remediated |

## Residual Detection Risk

`DET-001` is intentionally classified as partially remediated.

IAM Access Analyzer is now active and provides external-access analysis. GuardDuty and Security Hub were not enabled because the assessed AWS account returned service subscription errors during baseline validation.

The project does not claim those controls are enabled when the account does not support them. Enabling GuardDuty and Security Hub remains a production recommendation where account capabilities permit.

## Terraform Drift Validation

Post-remediation Terraform validation returned:

`No changes. Your infrastructure matches the configuration.`

This confirms that the deployed AWS infrastructure matches the hardened Terraform configuration at the time of validation.

## Key Before/After Outcomes

| Control | Before | After |
|---|---|---|
| Privileged lab IAM user | AdministratorAccess + no MFA | Removed |
| SSH exposure | TCP/22 from `0.0.0.0/0` | No TCP/22 ingress |
| Administrative access | Public SSH exposure | AWS Systems Manager |
| EC2 metadata | IMDSv1 permitted | IMDSv2 required |
| Root EBS encryption | Disabled | Enabled |
| Regional EBS encryption default | Disabled | Enabled |
| S3 anonymous access | HTTP 200 | HTTP 403 |
| S3 Block Public Access | Disabled | Enabled |
| S3 versioning | Suspended | Enabled |
| CloudTrail managed trail | Absent | Active multi-Region trail |
| IAM Access Analyzer | Absent | Active |
