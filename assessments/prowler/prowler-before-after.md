# Prowler Before vs After Security Comparison

Both assessments were performed with **Prowler 5.42.0** in `us-east-1`.

The comparison focuses on controls explicitly mapped to the project's risk register rather than treating unrelated account-wide scanner findings as project failures.

| Finding | Prowler Control | Before | After | Outcome |
|---|---|---|---|---|
| IAM-001 | `iam_user_administrator_access_policy` | FAIL | Project identity removed | Remediated |
| IAM-001 | `iam_user_mfa_enabled_console_access` | FAIL | Project identity removed | Remediated |
| S3-001 | `s3_bucket_public_access` | FAIL | PASS | Remediated |
| S3-001 | `s3_bucket_level_public_access_block` | FAIL | PASS | Remediated |
| NET-001 | `ec2_instance_port_ssh_exposed_to_internet` | FAIL | PASS | Remediated |
| NET-001 | `ec2_securitygroup_allow_ingress_from_internet_to_tcp_port_22` | FAIL | PASS | Remediated |
| EC2-001 | `ec2_instance_imdsv2_enabled` | FAIL | PASS | Remediated |
| EC2-002 | EBS encryption controls | Baseline weakness validated independently | PASS | Remediated |
| LOG-001 | `cloudtrail_multi_region_enabled` | FAIL | PASS | Remediated |
| DET-001 | `accessanalyzer_enabled` | FAIL | PASS | Partially remediated |

## Key Security Transitions

### Public S3 Exposure

**Before:** Prowler detected the demonstration S3 bucket as publicly accessible and lacking sufficient bucket-level public-access protections.

**After:** Both the public-access and Block Public Access checks pass.

Manual testing independently changed from anonymous HTTP `200` to HTTP `403`.

### Internet-Exposed SSH

**Before:** Prowler detected both the EC2 workload and its security group exposing TCP/22 to the Internet.

**After:** Both checks pass for the active secure workload.

Manual external TCP testing independently confirmed that port 22 is no longer reachable.

### EC2 Metadata Protection

**Before:** IMDSv2 was not required.

**After:** `ec2_instance_imdsv2_enabled` passes and manual validation confirms `HttpTokens=required`.

### Storage Encryption

**Before:** The original workload root EBS volume was unencrypted and regional EBS encryption by default was disabled.

**After:** Prowler reports PASS for both the encrypted workload volume and regional EBS encryption-by-default.

### Durable Audit Logging

**Before:** Prowler reported no qualifying multi-Region customer-managed CloudTrail trail.

**After:** `cloudtrail_multi_region_enabled` passes. Manual validation confirms the trail is actively logging, includes global service events, and has log-file validation enabled.

### External Access Analysis

**Before:** IAM Access Analyzer was not enabled.

**After:** `accessanalyzer_enabled` passes and manual validation reports the analyzer as ACTIVE.

### Privileged Lab IAM User

**Before:** The project intentionally provisioned `cloudsec-lab-admin` with AdministratorAccess, console authentication, and no MFA.

**After:** The identity was removed entirely, so no post-remediation Prowler finding exists for that project identity.

Account-wide IAM findings associated with other identities are treated as residual risks outside the controlled workload scope.

## Interpretation

A scanner PASS does not independently prove that compromise is impossible.

The post-remediation conclusions are supported by multiple evidence sources:

1. Terraform configuration and zero-drift validation
2. AWS CLI control verification
3. External connectivity and anonymous-access testing
4. Prowler 5.42.0 post-remediation assessment
5. ScoutSuite validation to be performed independently

This layered validation provides stronger assurance than relying on a single CSPM scanner score.
