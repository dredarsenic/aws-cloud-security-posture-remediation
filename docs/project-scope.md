# AWS Cloud Security Posture Assessment & Remediation

## Business Scenario

A growing digital services company has migrated a customer-facing workload to AWS to support increasing demand.

The environment was deployed quickly to meet business deadlines. Before the platform begins handling larger volumes of customer and operational data, the security team has been asked to assess whether the AWS environment provides appropriate controls for identity, data protection, administrative access, logging, and threat detection.

The assessment focuses on identifying cloud misconfigurations that could contribute to:

- AWS account compromise
- Unauthorized access to customer or operational data
- Workload compromise
- Service disruption
- Excessive administrative access
- Reduced incident detection and investigation capability

## Business Objective

The organization needs to reduce cloud security risk without slowing continued adoption of AWS.

The objective of this project is to:

1. Build a controlled AWS environment containing realistic security misconfigurations.
2. Assess the environment using automated and manual security techniques.
3. Validate meaningful findings instead of relying only on scanner output.
4. Translate technical weaknesses into business risk.
5. Prioritize remediation based on exploitability and potential blast radius.
6. Implement remediation through Terraform.
7. Reassess the environment to confirm security posture improvement.
8. Document residual risk and recommendations.

## Assessment Scope

The assessment covers:

- AWS Identity and Access Management (IAM)
- Amazon EC2
- Amazon VPC and Security Groups
- Amazon S3
- CloudTrail and audit logging
- EC2 Instance Metadata Service controls
- AWS-native threat detection and security monitoring
- Infrastructure as Code security

## Methodology

The engagement follows this workflow:

1. Infrastructure deployment with Terraform
2. Baseline security assessment
3. ScoutSuite assessment
4. Prowler assessment
5. AWS CLI and console validation
6. Risk and blast-radius analysis
7. Prioritized remediation
8. Terraform-based hardening
9. Post-remediation reassessment
10. Before-and-after security posture comparison

## Security Tools

The project will use:

- Terraform
- AWS CLI
- ScoutSuite
- Prowler
- AWS-native security services
- GitHub Actions for Infrastructure as Code validation

## Safety and Ethics

This project is performed only within an isolated AWS lab environment owned and controlled by the project author.

No production systems, customer information, employer resources, real credentials, or sensitive data are used.

Any intentionally exposed resources contain only harmless test data.

The purpose of the insecure configuration is defensive security assessment, validation, remediation, and security engineering.

## Risk Register

The finalized insecure-baseline findings, severity rationale, business impact, and remediation priorities are documented in [`risk-register.md`](risk-register.md).

The risk register is frozen before remediation so that post-remediation results can be compared against the same baseline criteria.
