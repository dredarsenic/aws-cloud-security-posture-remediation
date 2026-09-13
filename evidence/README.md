# Security Assessment Evidence

This directory contains sanitized evidence collected during the authorized AWS Cloud Security Posture Assessment & Remediation lab.

Runtime identifiers such as public IP addresses, DNS names, and S3 bucket names have been redacted from the published evidence. Unsanitized evidence is maintained locally and is excluded from version control.

## Baseline Findings

| Finding | Description | Evidence |
|---|---|---|
| NET-001 | SSH administrative access exposed to `0.0.0.0/0` | `ec2/security-group-before.txt`, `ec2/ssh-reachability-before.txt` |
| EC2-001 | IMDSv2 not enforced (`HttpTokens=optional`) | `ec2/metadata-options-before.txt` |
| EC2-002 | EC2 root EBS volume is not encrypted at rest | `ec2/ebs-encryption-before.txt`, `ec2/ebs-default-encryption-before.json` |
| S3-001 | Public S3 object accessible without AWS authentication | `s3/anonymous-object-access-before.txt`, `s3/policy-status-before.txt`, `s3/public-access-block-before.txt`, `s3/bucket-policy-before.txt` |
| IAM-001 | Privileged IAM console user with `AdministratorAccess` and no MFA | `iam/attached-policies-before.txt`, `iam/login-profile-before.txt`, `iam/mfa-devices-before.txt`, `iam/access-keys-before.txt`, `iam/credential-report-before.csv` |
| LOG-001 | No durable customer-managed CloudTrail audit trail | `logging/trails-before.json`, `logging/event-history-before.txt`, `logging/event-data-stores-before.txt` |
| DET-001 | Limited AWS-native threat detection and external-access analysis | `detection/guardduty-before.txt`, `detection/securityhub-before.txt`, `detection/access-analyzers-before.json` |

These artifacts represent the insecure baseline. Corresponding post-remediation evidence will be collected later for before-and-after comparison.
