# AWS Cloud Security Remediation Plan

## Purpose

This document defines the target security architecture and implementation strategy for remediating the findings identified during the insecure baseline assessment.

The remediation phase preserves `terraform/insecure/` as the reproducible baseline while implementing the hardened target configuration under `terraform/secure/`.

The existing AWS environment will be remediated using the existing Terraform state so that before-and-after validation represents an actual security transition rather than two unrelated deployments.

---

## Remediation Strategy

| Finding | Baseline | Target State | Implementation |
|---|---|---|---|
| IAM-001 | Privileged IAM console user with `AdministratorAccess` and no MFA | Remove simulated privileged human IAM user from workload IaC | Destroy IAM user, login profile, and AdministratorAccess attachment |
| S3-001 | Public bucket policy and disabled Block Public Access | Private S3 bucket with full Block Public Access, versioning and TLS-only access | Modify bucket controls and remove public policy |
| NET-001 | SSH TCP/22 exposed to `0.0.0.0/0` | No public SSH administration | Remove SSH ingress and use AWS Systems Manager Session Manager |
| EC2-001 | IMDSv1 permitted through `HttpTokens=optional` | IMDSv2 required | Set `HttpTokens=required` |
| EC2-002 | Unencrypted EC2 root EBS volume | Encrypted root volume | Replace EC2 instance with encrypted EBS root volume |
| LOG-001 | No durable customer-managed CloudTrail trail | Multi-Region CloudTrail with protected S3 archive and log validation | Deploy dedicated CloudTrail logging architecture |
| DET-001 | No IAM Access Analyzer and limited managed detection | Enable Access Analyzer; enable additional managed detection where account capabilities permit | Terraform Access Analyzer plus documented residual controls |

---

## IAM-001 — Privileged Human Identity

### Baseline

The lab contains a console-enabled IAM user with the AWS-managed `AdministratorAccess` policy and no MFA device.

### Target

The secure infrastructure will not provision a long-lived privileged human IAM user.

The lab administrator resources will be removed:

- IAM login profile
- AdministratorAccess policy attachment
- IAM user

Human administrative access in production should use temporary federated credentials with MFA and role-based authorization rather than permanent IAM users.

The operator identity used to execute Terraform is outside the workload architecture and will not be weakened or modified as part of this remediation.

---

## S3-001 — Public Object Storage

### Baseline

The demonstration S3 bucket:

- permits `s3:GetObject` to `Principal: "*"`
- has all bucket-level Block Public Access settings disabled
- permits anonymous retrieval of the demonstration object
- has versioning suspended

### Target

The hardened bucket will:

- remove anonymous public access
- enable all four S3 Block Public Access controls
- enable versioning
- explicitly deny requests that do not use TLS
- retain encryption at rest

The harmless demonstration object may remain in the bucket so that post-remediation testing can prove that anonymous retrieval changes from HTTP 200 to HTTP 403.

---

## NET-001 — Internet-Exposed SSH

### Baseline

TCP/22 is allowed from `0.0.0.0/0`, and external TCP reachability has been validated.

### Target

The public SSH rule will be removed entirely.

Administrative access will use AWS Systems Manager Session Manager.

The workload will receive:

- an EC2 IAM role
- an instance profile
- `AmazonSSMManagedInstanceCore`

The web workload may remain publicly reachable on TCP/80 because public HTTP access is an intended workload requirement and is not itself treated as a vulnerability.

---

## EC2-001 — IMDSv2 Not Enforced

### Baseline

The instance metadata configuration permits IMDSv1:

`HttpTokens = optional`

### Target

The hardened EC2 instance will use:

`HttpTokens = required`

The metadata endpoint will remain enabled because AWS services and instance software may legitimately require metadata access.

---

## EC2-002 — Unencrypted Root Storage

### Baseline

The EC2 root EBS volume is unencrypted.

### Target

The replacement EC2 instance will use an encrypted root EBS volume.

This requires instance replacement because encryption cannot be enabled directly on an existing unencrypted EBS volume.

The workload is disposable and contains no production or customer data, making controlled replacement appropriate for this lab.

Regional EBS encryption by default will also be enabled in `us-east-1` so that future EBS volumes are encrypted automatically unless explicitly configured otherwise.

---

## LOG-001 — Durable Audit Logging

### Baseline

CloudTrail Event History is available, but the account has no customer-managed trail and no CloudTrail Lake event data store.

### Target

The secure architecture will deploy:

- a dedicated CloudTrail S3 log bucket
- S3 Block Public Access
- bucket versioning
- encryption at rest
- TLS-only access
- a multi-Region CloudTrail trail
- global service event collection
- log file validation

CloudTrail management-event logging will provide durable audit evidence for incident response and forensic reconstruction.

---

## DET-001 — Limited Security Detection

### Baseline

The assessment identified:

- no IAM Access Analyzer
- GuardDuty unavailable without service subscription/enablement
- Security Hub unavailable without service subscription/enablement

### Target

IAM Access Analyzer will be enabled through Terraform in the assessment Region.

GuardDuty and Security Hub will be enabled only if supported by the lab account. If account subscription restrictions prevent deployment, they will be documented as residual risk rather than falsely represented as remediated.

---

## Terraform State Strategy

`terraform/insecure/` remains the immutable source representation of the vulnerable baseline.

`terraform/secure/` will contain the hardened target configuration.

Before remediation is applied:

1. The existing local Terraform state will be backed up outside the Git repository.
2. The authoritative local state will be moved from `terraform/insecure/` to `terraform/secure/`.
3. The insecure directory will no longer be used to manage the live environment.
4. Terraform will refresh the migrated state against the hardened configuration.
5. The remediation plan will be reviewed before `terraform apply`.

Terraform state files remain excluded from version control because they can contain sensitive infrastructure metadata.

---

## Expected Resource Lifecycle

| Resource | Expected Action |
|---|---|
| VPC | Retain |
| Internet Gateway | Retain |
| Public subnet | Retain |
| Route table | Retain |
| EC2 security group | Modify |
| EC2 instance | Replace |
| Root EBS volume | Replace with encrypted volume |
| Public S3 bucket | Harden in place |
| Demo S3 object | Retain |
| Lab privileged IAM user | Destroy |
| EC2 SSM role/profile | Create |
| IAM Access Analyzer | Create |
| CloudTrail log bucket | Create |
| CloudTrail trail | Create |

---

## Validation Strategy

The secure environment will be validated using the same methods used for the baseline:

- AWS CLI
- controlled network/access tests
- Prowler 5.42.0
- ScoutSuite 5.14.0

Where possible, the same commands and scanner versions will be reused so that before-and-after results are directly comparable.

Expected examples include:

- anonymous S3 access: `200` → `403`
- SSH reachability: open → blocked
- EC2 metadata tokens: optional → required
- EBS encryption: false → true
- CloudTrail customer-managed trails: zero → one
- IAM Access Analyzer: absent → active
- privileged lab IAM user: present → removed

---

## Change Control Principle

No production, employer, or customer resources are part of this environment.

Every remediation will be reviewed using `terraform plan` before being applied.

Destructive or replacement operations will be explicitly identified and reviewed before approval.
