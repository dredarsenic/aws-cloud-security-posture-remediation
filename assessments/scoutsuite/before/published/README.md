# ScoutSuite Baseline Assessment

ScoutSuite 5.14.0 was used as a second independent cloud security assessment engine against the intentionally insecure AWS lab environment.

The complete raw ScoutSuite report contains AWS account identifiers, resource identifiers, public network information, IAM metadata, and other runtime details. Raw output is therefore retained locally under `../raw/` and excluded from version control.

Only sanitized, project-relevant findings are published in this directory.

## Findings Corroborated by ScoutSuite

| Project Finding | ScoutSuite Finding | Result |
|---|---|---|
| IAM-001 | `iam-managed-policy-allows-full-privileges` | Full administrative privileges detected |
| IAM-001 | `iam-user-without-mfa` | IAM users without MFA detected |
| S3-001 | `s3-bucket-world-Get-policy` | Object read access authorized to all principals |
| NET-001 | `ec2-security-group-opens-SSH-port-to-all` | SSH exposed to all source addresses |
| LOG-001 | `cloudtrail-not-configured` | No customer-managed CloudTrail trail detected |

## Coverage Across Assessment Methods

| Finding | Manual Validation | Prowler | ScoutSuite |
|---|---:|---:|---:|
| IAM-001 | Yes | Yes | Yes |
| S3-001 | Yes | Yes | Yes |
| NET-001 | Yes | Yes | Yes |
| EC2-001 | Yes | Yes | Not directly identified in the selected ScoutSuite findings |
| LOG-001 | Yes | Yes | Yes |
| DET-001 | Yes | Yes | Not directly identified in the selected ScoutSuite findings |

## Assessment Interpretation

Scanner findings were treated as evidence inputs rather than accepted blindly.

ScoutSuite performs account-wide assessment and therefore also identified controls outside the intentionally created lab resources, including root-account controls, account password-policy settings, default security-group rules, and EBS encryption settings.

Those observations are not automatically included in the project's primary risk register because their ownership and relationship to the controlled lab must first be validated.

For CloudTrail, ScoutSuite reported that the service was not configured. In this project, the finding is expressed more precisely as the absence of a durable customer-managed CloudTrail trail. AWS CloudTrail Event History was still available during manual validation.

## Scanner Limitations

Several AWS APIs returned subscription, opt-in, or account-tier errors during collection for services not used by the lab. These errors did not prevent assessment of the IAM, S3, EC2, and CloudTrail controls mapped to the project's primary findings.

The complete raw report remains local for forensic traceability and post-remediation comparison.
