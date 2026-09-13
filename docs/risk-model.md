# Initial Cloud Risk Model

This document defines the security weaknesses intentionally introduced into the lab environment.

The final severity of each finding will be validated during the assessment rather than relying solely on automated scanner classifications.

| ID | Security Weakness | Security Risk | Potential Business Impact | Initial Priority |
|---|---|---|---|---|
| IAM-001 | Privileged IAM user without MFA | Compromise of privileged credentials could provide extensive AWS access | Account takeover, unauthorized resource modification, data access, service disruption | Critical |
| S3-001 | Publicly readable S3 object | Internet users may access data without authentication | Data exposure, customer trust impact, possible regulatory consequences | High |
| NET-001 | SSH exposed to `0.0.0.0/0` | Administrative service is reachable from the public internet | Increased attack surface and potential unauthorized server access | High |
| LOG-001 | Insufficient AWS audit logging | Important administrative activity may not be adequately recorded | Delayed detection, incomplete forensic investigation, reduced accountability | High |
| EC2-001 | IMDSv2 not enforced | Instance metadata protections are weaker than recommended | Increased risk of instance-role credential exposure if another workload weakness exists | Medium |
| DET-001 | Limited cloud threat detection | Suspicious AWS activity may not generate centralized security findings | Delayed identification and response to malicious activity | Medium |

## Risk Evaluation Principles

Findings will be evaluated using the following factors:

### Exploitability

How easily could the weakness be abused?

### Privilege

What permissions or access could an attacker obtain?

### Exposure

Is the resource internet-facing, internally accessible, or restricted?

### Blast Radius

How many AWS services, resources, applications, or data stores could be affected?

### Business Impact

Could exploitation cause:

- Confidentiality loss
- Integrity loss
- Service disruption
- Financial impact
- Regulatory exposure
- Customer trust impact

### Detection Capability

Would the organization be able to detect and investigate abuse of the affected resource?

## Important Distinction

A security misconfiguration does not automatically mean that a system has been compromised.

For example, exposing SSH to the internet increases attack surface but does not by itself provide authenticated access to an EC2 instance.

The assessment will distinguish between:

- Exposure
- Exploitability
- Successful compromise
- Potential business impact
