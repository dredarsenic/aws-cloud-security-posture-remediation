# Final Security Assessment & Risk Closure Report

## AWS Cloud Security Posture Assessment & Remediation

This report summarizes the final security posture of the AWS cloud security remediation project after infrastructure hardening, direct control validation, and independent reassessment with Prowler and ScoutSuite.

The project began with an intentionally insecure AWS workload designed to represent realistic cloud security weaknesses. The environment was assessed, findings were mapped to business risk, remediation was implemented through Terraform, and the resulting controls were independently validated.

The final assessment distinguishes between:

- project-level remediation;
- account-wide residual risk;
- scanner findings;
- validated control state;
- remaining production recommendations.

A scanner PASS is not treated as proof that compromise is impossible, and a scanner FAIL is not treated as proof that exploitation occurred.

---

## Executive Summary

Seven primary risks were tracked during the project.

| Finding | Initial Severity | Final Project Status |
|---|---:|---|
| IAM-001 | Critical | Remediated for project; account-level residual IAM risk remains |
| S3-001 | High | Remediated |
| NET-001 | High | Remediated |
| LOG-001 | High | Remediated |
| EC2-001 | Medium | Remediated |
| EC2-002 | Medium | Remediated for workload and `us-east-1`; multi-Region residual remains |
| DET-001 | Medium | Partially remediated |

The most material project attack paths were reduced or removed:

- the intentionally overprivileged project IAM user was deleted;
- public SSH exposure was removed;
- S3 anonymous read access changed from HTTP `200` to HTTP `403`;
- IMDSv2 became mandatory;
- the active EC2 root EBS volume became encrypted;
- EBS encryption by default was enabled in the project Region;
- a durable multi-Region CloudTrail trail was created;
- IAM Access Analyzer was enabled;
- Terraform post-remediation validation returned zero drift.

Independent Prowler and ScoutSuite reassessments corroborated the project-level remediation.

---

## Scope

The assessment focuses on the AWS resources intentionally created for the project and the controls mapped to the project risk register.

Primary services assessed:

- IAM
- EC2
- VPC security groups
- EBS
- S3
- CloudTrail
- IAM Access Analyzer
- AWS Systems Manager

The project does not claim to remediate every account-level issue discovered by the scanners.

Where Prowler or ScoutSuite identified findings associated with resources or IAM identities outside the Terraform-managed project, those findings were retained as residual account-level risk.

---

## Assessment Methodology

The final conclusions are based on multiple independent evidence sources:

1. Terraform configuration review
2. Terraform post-apply drift validation
3. AWS CLI control verification
4. External TCP connectivity testing
5. Anonymous S3 access testing
6. Prowler 5.42.0 before/after assessment
7. ScoutSuite 5.14.0 before/after assessment

This approach provides stronger assurance than relying on a single CSPM scanner score.

---

# Risk Closure Analysis

## IAM-001: Privileged IAM Console User Without MFA

**Initial severity:** Critical

### Baseline Condition

The project intentionally provisioned a dedicated IAM console user with:

- `AdministratorAccess`;
- console authentication;
- no MFA.

This represented a high-impact identity risk because compromise of the credentials could provide unrestricted administrative control over the AWS environment.

### Remediation

The intentionally vulnerable project identity `cloudsec-lab-admin` was removed entirely.

EC2 administrative access was moved to AWS Systems Manager using an instance role with the AWS-managed `AmazonSSMManagedInstanceCore` policy.

### Validation

Post-remediation validation confirmed:

- `cloudsec-lab-admin` no longer exists;
- ScoutSuite occurrences for the identity changed from `9` to `0`;
- Prowler returned no post-remediation rows for that project identity;
- the replacement EC2 workload is registered and online in Systems Manager.

### Residual Risk

Prowler and ScoutSuite continue to report IAM findings associated with other account identities outside the Terraform-managed project.

These findings are retained as account-level residual risk and are not represented as failures of the project remediation.

### Final Status

**Remediated for project scope. Account-level IAM residual risk remains.**

---

## S3-001: Publicly Readable S3 Object

**Initial severity:** High

### Baseline Condition

The project S3 bucket allowed anonymous object reads through a public bucket policy and disabled Block Public Access controls.

Manual anonymous access returned:

```text
HTTP 200
```

### Remediation

The hardened configuration:

- removed public read authorization;
- enabled all four S3 Block Public Access settings;
- enforced bucket-owner controls;
- enabled versioning;
- explicitly configured AES256 server-side encryption;
- added a TLS-only bucket policy.

### Validation

Manual anonymous access returned:

```text
HTTP 403
```

Prowler reported PASS for:

- `s3_bucket_public_access`;
- `s3_bucket_level_public_access_block`.

ScoutSuite changed:

```text
s3-bucket-world-Get-policy
1 / 1 flagged -> 0 / 4 flagged
```

### Final Status

**Remediated.**

---

## NET-001: SSH Exposed to the Internet

**Initial severity:** High

### Baseline Condition

The baseline security group allowed:

```text
TCP/22 -> 0.0.0.0/0
```

This created an unnecessary public administrative attack surface.

### Remediation

Public SSH access was removed completely.

Administrative access was moved to AWS Systems Manager rather than simply restricting the SSH source range.

### Validation

Post-remediation validation confirmed:

- no TCP/22 rule exists in the secure security group;
- external TCP/22 connectivity timed out;
- the secure EC2 instance remains operational;
- Systems Manager reports the instance online.

Prowler reported PASS for:

- `ec2_instance_port_ssh_exposed_to_internet`;
- `ec2_securitygroup_allow_ingress_from_internet_to_tcp_port_22`.

ScoutSuite changed:

```text
ec2-security-group-opens-SSH-port-to-all
1 / 5 flagged -> 0 / 20 flagged
```

### Final Status

**Remediated.**

---

## LOG-001: No Durable Customer-Managed CloudTrail Trail

**Initial severity:** High

### Baseline Condition

AWS CloudTrail Event History was available, but there was no durable customer-managed CloudTrail trail.

Event History and a deliberately configured audit trail are treated as different security capabilities.

### Remediation

Terraform created a dedicated CloudTrail configuration with:

- multi-Region coverage;
- global service events;
- management-event logging;
- active logging;
- log-file integrity validation;
- dedicated S3 audit-log storage;
- S3 versioning;
- defined lifecycle retention.

### Validation

Direct AWS validation confirmed:

- the trail is multi-Region;
- logging is active;
- global service events are included;
- log-file validation is enabled;
- recent delivery succeeded without a delivery error.

Prowler reported PASS for:

```text
cloudtrail_multi_region_enabled
```

ScoutSuite changed:

```text
cloudtrail-not-configured
1 / 1 flagged -> 0 / 17 flagged
```

### Residual Considerations

The lab CloudTrail storage configuration demonstrates durable logging but is not presented as a complete production immutability design.

Production environments should consider:

- separate logging accounts;
- stricter deletion protection;
- customer-managed KMS keys;
- immutable retention controls;
- alerting on trail configuration changes.

### Final Status

**Remediated for project scope.**

---

## EC2-001: IMDSv2 Not Enforced

**Initial severity:** Medium

### Baseline Condition

The baseline EC2 workload permitted metadata access without requiring IMDSv2 session tokens.

### Remediation

The secure EC2 configuration enforces:

```text
HttpEndpoint = enabled
HttpTokens   = required
HopLimit     = 1
```

### Validation

AWS CLI validation confirmed IMDSv2 token enforcement.

Prowler reported PASS for:

```text
ec2_instance_imdsv2_enabled
```

### Final Status

**Remediated.**

---

## EC2-002: Unencrypted EC2 Root EBS Volume

**Initial severity:** Medium

### Baseline Condition

The original EC2 root EBS volume was unencrypted.

Regional EBS encryption by default was also disabled in the project Region.

### Remediation

Terraform:

- created an encrypted replacement root volume;
- enabled EBS encryption by default in `us-east-1`.

### Validation

AWS CLI validation confirmed:

- the active root EBS volume is encrypted;
- EBS encryption by default is enabled in `us-east-1`.

Prowler reported PASS for:

- `ec2_ebs_volume_encryption`;
- `ec2_ebs_default_encryption`.

ScoutSuite changed:

```text
ec2-ebs-volume-not-encrypted
1 / 1 flagged -> 0 / 1 flagged
```

### Account-Wide Residual Risk

ScoutSuite evaluated 17 Regions after remediation and reported:

```text
ec2-ebs-default-encryption-disabled
16 / 17 flagged
```

Direct AWS validation confirmed:

- `us-east-1`: enabled;
- sixteen other queried Regions: disabled.

The baseline ScoutSuite scan checked only one item for this rule, while the post-remediation scan checked seventeen. The increase in flagged count must therefore not be interpreted as a simple security regression because scanner coverage changed materially.

### Final Status

**Remediated for the project workload and `us-east-1`. Multi-Region account-level residual risk remains.**

---

## DET-001: Limited AWS-Native Detection and Access Analysis

**Initial severity:** Medium

### Baseline Condition

The baseline environment did not have IAM Access Analyzer configured.

GuardDuty and Security Hub were also unavailable in the assessed account due service subscription restrictions.

### Remediation

Terraform enabled an account-level IAM Access Analyzer.

### Validation

AWS CLI validation confirmed the analyzer is:

```text
ACTIVE
```

Prowler reported PASS for:

```text
accessanalyzer_enabled
```

Prowler also reported the analyzer with no active findings at the time of assessment.

### Residual Risk

GuardDuty and Security Hub were not enabled because the account returned service subscription errors.

The project therefore does not claim complete AWS-native detection coverage.

### Final Status

**Partially remediated.**

---

# Independent Scanner Comparison

## Prowler

Both Prowler assessments used version **5.42.0** and the same primary Region.

| Assessment | Checks | Passed | Failed |
|---|---:|---:|---:|
| Baseline | 648 | 94 | 107 |
| Post-remediation | 648 | 142 | 99 |

The overall account totals are not treated as the primary success metric because Prowler evaluates resources outside the Terraform project and the remediation itself adds new AWS resources.

Project-specific PASS/FAIL transitions are documented in:

[`../assessments/prowler/prowler-before-after.md`](../assessments/prowler/prowler-before-after.md)

---

## ScoutSuite

Both ScoutSuite assessments used version **5.14.0**.

| Rule | Baseline | Post-Remediation |
|---|---:|---:|
| `iam-managed-policy-allows-full-privileges` | 1 / 24 flagged | 1 / 28 flagged |
| `iam-user-without-mfa` | 2 / 3 flagged | 1 / 2 flagged |
| `s3-bucket-world-Get-policy` | 1 / 1 flagged | 0 / 4 flagged |
| `ec2-security-group-opens-SSH-port-to-all` | 1 / 5 flagged | 0 / 20 flagged |
| `cloudtrail-not-configured` | 1 / 1 flagged | 0 / 17 flagged |
| `ec2-ebs-volume-not-encrypted` | 1 / 1 flagged | 0 / 1 flagged |
| `ec2-ebs-default-encryption-disabled` | 1 / 1 flagged | 16 / 17 flagged |

ScoutSuite also showed:

```text
cloudsec-lab-admin
baseline occurrences: 9
post-remediation occurrences: 0
```

The IAM and multi-Region EBS findings that remain are documented as residual account-level risk rather than hidden.

Detailed comparison:

[`../assessments/scoutsuite/scoutsuite-before-after.md`](../assessments/scoutsuite/scoutsuite-before-after.md)

---

# Terraform Validation

After remediation, Terraform was run against the deployed environment.

Result:

```text
No changes. Your infrastructure matches the configuration.
```

This confirms that the deployed project infrastructure matched the hardened Terraform configuration at the time of validation.

---

# Final Risk Status

| Finding | Initial Severity | Project Status | Residual Risk |
|---|---:|---|---|
| IAM-001 | Critical | Remediated | Other account IAM findings remain outside project scope |
| S3-001 | High | Remediated | Production data-governance controls still recommended |
| NET-001 | High | Remediated | Public HTTP remains intentionally exposed for the demo workload |
| LOG-001 | High | Remediated | Production immutability and centralized logging recommended |
| EC2-001 | Medium | Remediated | Continue enforcing through IaC/policy guardrails |
| EC2-002 | Medium | Remediated for workload/`us-east-1` | EBS default encryption disabled in 16 other queried Regions |
| DET-001 | Medium | Partially remediated | GuardDuty and Security Hub unavailable in assessed account |

---

# Residual Risk and Production Recommendations

The project is intentionally scoped to a controlled lab workload. A production AWS security program should extend the remediation with additional preventive, detective, and governance controls.

Recommended next steps include:

1. **Centralized identity federation**
   - minimize long-lived IAM users;
   - use AWS IAM Identity Center or enterprise federation;
   - enforce phishing-resistant MFA.

2. **Organization-level governance**
   - use AWS Organizations;
   - define Service Control Policies;
   - restrict unused AWS Regions;
   - enforce encryption and logging guardrails.

3. **Threat detection**
   - enable Amazon GuardDuty where account capabilities permit;
   - enable AWS Security Hub;
   - integrate findings with centralized incident workflows.

4. **Configuration monitoring**
   - deploy AWS Config;
   - continuously evaluate security-relevant configuration drift;
   - alert on unauthorized changes.

5. **Encryption governance**
   - enable EBS encryption by default in every approved Region;
   - consider customer-managed KMS keys for sensitive workloads;
   - apply least-privilege KMS policies.

6. **Audit-log protection**
   - centralize CloudTrail into a dedicated logging account;
   - apply stronger deletion protection and immutable retention;
   - monitor changes to trails and log-bucket policies.

7. **Backup and recovery**
   - define AWS Backup policies based on business RPO/RTO;
   - use cross-account or cross-Region copies where appropriate;
   - test recovery procedures.

8. **Application transport security**
   - terminate production traffic over HTTPS;
   - use ACM-managed certificates;
   - redirect HTTP to HTTPS.

9. **Continuous security assessment**
   - integrate Terraform validation, Prowler, and policy checks into CI/CD;
   - review residual findings regularly;
   - track exceptions with ownership and expiration dates.

---

# Assessment Limitations

This project has several deliberate limitations.

- It is a controlled security lab, not a complete enterprise AWS landing zone.
- Scanner coverage differs between some before and after checks.
- ScoutSuite encountered subscription, opt-in, or account-tier collection errors for several AWS services not used by the lab.
- GuardDuty and Security Hub were unavailable in the assessed account.
- Account-wide findings unrelated to Terraform-managed resources were not automatically modified.
- No claim is made that a vulnerable configuration resulted in actual exploitation or compromise.
- No penetration test was performed against third-party or unauthorized infrastructure.

---

# Security Outcome

The project demonstrates a complete cloud security engineering workflow:

```text
Identify
   |
Validate
   |
Prioritize
   |
Remediate as Code
   |
Verify
   |
Reassess
   |
Document Residual Risk
```

The most important outcome is not that every scanner finding disappeared.

The important outcome is that the project:

- identified material AWS risks;
- validated them independently;
- translated them into business-relevant security concerns;
- remediated the controlled infrastructure through Terraform;
- removed or reduced specific attack paths;
- proved the resulting changes through multiple evidence sources;
- preserved account-level residual risk rather than presenting an artificially perfect environment.

That distinction is central to real-world cloud security engineering.

---

## Supporting Documentation

- [`project-scope.md`](project-scope.md)
- [`risk-model.md`](risk-model.md)
- [`risk-register.md`](risk-register.md)
- [`remediation-plan.md`](remediation-plan.md)
- [`../assessments/prowler/prowler-before-after.md`](../assessments/prowler/prowler-before-after.md)
- [`../assessments/scoutsuite/scoutsuite-before-after.md`](../assessments/scoutsuite/scoutsuite-before-after.md)
- [`../evidence/remediation/README.md`](../evidence/remediation/README.md)
