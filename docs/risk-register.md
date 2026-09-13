# AWS Cloud Security Risk Register

## Assessment Context

This risk register represents the finalized insecure baseline for the AWS Cloud Security Posture Assessment & Remediation project.

Findings were identified through a combination of:

- Manual AWS CLI validation
- Controlled connectivity and anonymous-access testing
- Prowler 5.42.0
- ScoutSuite 5.14.0

Scanner severity ratings were treated as assessment inputs rather than accepted automatically. Final project severities are based on exploitability, exposure, privilege, blast radius, business impact, and available detection capability.

---

## Final Risk Register

| ID | Finding | Severity | Exploitability | Business Impact | Validation |
|---|---|---|---|---|---|
| IAM-001 | Privileged IAM console user with `AdministratorAccess` and no MFA | Critical | High if credentials are compromised | Full account compromise, resource modification/deletion, data exposure, service disruption | Manual + Prowler + ScoutSuite |
| S3-001 | Publicly readable S3 object storage | High | Direct anonymous access confirmed | Potential unauthorized data disclosure and compliance/customer-trust impact | Manual + Prowler + ScoutSuite |
| NET-001 | SSH exposed to `0.0.0.0/0` | High | Internet reachable, authentication still required | Increased attack surface, credential attacks, possible host compromise if authentication is defeated | Manual + Prowler + ScoutSuite |
| LOG-001 | No durable customer-managed CloudTrail audit trail | High | Not a direct exploitation path | Reduced forensic reconstruction, long-term auditability, incident investigation and evidence integrity | Manual + Prowler + ScoutSuite |
| EC2-001 | IMDSv2 not enforced | Medium | Requires an additional path capable of reaching instance metadata | Potential credential exposure if an SSRF or instance-level weakness exists | Manual + Prowler |
| EC2-002 | EC2 root EBS volume not encrypted | Medium | Requires access to AWS storage, snapshots, or associated infrastructure | Increased confidentiality and compliance risk for data at rest | Manual + ScoutSuite |
| DET-001 | Limited AWS-native threat detection and external-access analysis | Medium | Not a direct exploitation path | Reduced ability to identify malicious behavior, exposure, credential misuse, and suspicious activity | Manual + Prowler |

---

## Risk Analysis

### IAM-001 — Privileged IAM User Without MFA

The lab administrator has interactive console access and the AWS-managed `AdministratorAccess` policy. No MFA device is configured.

The combination of reusable password authentication, unrestricted administrative privileges, and absent MFA creates the largest blast radius in the environment. Successful credential compromise could provide control over most resources in the AWS account.

**Target remediation:**

- Remove `AdministratorAccess`
- Replace unrestricted privileges with least-privilege permissions
- Require MFA for privileged human access
- Prefer temporary or federated access over long-lived IAM users in production architectures

---

### S3-001 — Public S3 Object Access

The lab S3 bucket permits `s3:GetObject` to `Principal: "*"`, bucket-level Block Public Access protections are disabled, and anonymous HTTP access to the demonstration object returned HTTP 200.

This represents confirmed exposure rather than a theoretical configuration weakness.

**Target remediation:**

- Remove the public bucket policy
- Enable all S3 Block Public Access settings
- Enable bucket versioning
- Require TLS for bucket access
- Preserve encryption at rest

---

### NET-001 — Internet-Exposed SSH

The EC2 security group permits TCP/22 from `0.0.0.0/0`, and external TCP reachability was independently confirmed.

This does not mean the EC2 instance has been compromised. SSH authentication remains required. The weakness is unnecessary Internet exposure of an administrative service.

**Target remediation:**

- Remove public SSH ingress
- Use AWS Systems Manager Session Manager for administrative access
- Retain only application ports that are required for the workload

---

### LOG-001 — Insufficient Durable Audit Logging

CloudTrail Event History provides recent management-event visibility, but the baseline contains no customer-managed CloudTrail trail and no CloudTrail Lake event data store.

The environment therefore lacks a durable audit architecture suitable for long-term investigation and controlled retention.

**Target remediation:**

- Create a multi-Region CloudTrail trail
- Deliver logs to a dedicated S3 bucket
- Enable log file validation
- Protect the logging bucket from public access
- Apply lifecycle retention controls

---

### EC2-001 — IMDSv2 Not Enforced

The EC2 instance is configured with:

`HttpTokens = optional`

This allows IMDSv1 requests in addition to IMDSv2.

The configuration does not itself expose credentials remotely. Risk becomes material when combined with another weakness, such as SSRF, application compromise, or local instance access.

**Target remediation:**

- Require IMDSv2
- Set `HttpTokens = required`

---

### EC2-002 — Unencrypted EBS Root Volume

The EC2 root volume is not encrypted and regional EBS encryption by default is disabled.

The volume is not directly Internet accessible, so its immediate exploitability is lower than the public-facing findings. However, encryption at rest is an important defense-in-depth and compliance control.

**Target remediation:**

- Deploy the secure workload with an encrypted root volume
- Enable EBS encryption by default where appropriate
- Use AWS KMS-backed encryption

---

### DET-001 — Limited AWS-Native Detection

The baseline assessment found no configured IAM Access Analyzer, while GuardDuty and Security Hub were unavailable without enabling/subscribing to the services in the assessed account.

This does not create a direct compromise path, but it reduces visibility and increases the likelihood that malicious or unintended activity remains undetected.

**Target remediation:**

- Enable IAM Access Analyzer
- Enable GuardDuty where supported
- Enable Security Hub where supported
- Aggregate relevant security findings for centralized review

---

## Remediation Priority

| Priority | Finding | Rationale |
|---|---|---|
| 1 | IAM-001 | Highest privilege and account-wide blast radius |
| 2 | S3-001 | Confirmed anonymous data exposure |
| 3 | NET-001 | Public administrative attack surface |
| 4 | LOG-001 | Required for durable incident investigation and accountability |
| 5 | EC2-001 | Reduces credential exposure through metadata attack chains |
| 6 | EC2-002 | Protects workload data at rest |
| 7 | DET-001 | Improves detection, exposure analysis, and response capability |

---

## Assessment Principle

The project distinguishes between:

- **Exposure** — a resource or service is reachable or accessible
- **Exploitability** — an attacker has a practical path to abuse the weakness
- **Compromise** — unauthorized access or control has actually occurred
- **Business impact** — the potential consequence if exploitation succeeds

No finding is described as a successful compromise unless evidence demonstrates that compromise occurred.
