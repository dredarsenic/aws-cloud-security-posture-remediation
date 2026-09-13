# ScoutSuite Post-Remediation Assessment

ScoutSuite 5.14.0 was used to reassess the AWS environment after the Terraform security remediation.

The raw ScoutSuite report is retained locally under `../raw/` and excluded from version control because it contains AWS account identifiers, ARNs, resource identifiers, IAM metadata, and other runtime information.

Only sanitized, project-relevant results are published here.

## Project Control Results

| Project Finding | ScoutSuite Finding | Before | After | Outcome |
|---|---|---:|---:|---|
| IAM-001 | `iam-managed-policy-allows-full-privileges` | 1 flagged / 24 checked | 1 flagged / 28 checked | Project identity removed; account-level residual remains |
| IAM-001 | `iam-user-without-mfa` | 2 flagged / 3 checked | 1 flagged / 2 checked | Project identity removed; account-level residual remains |
| S3-001 | `s3-bucket-world-Get-policy` | 1 flagged / 1 checked | 0 flagged / 4 checked | Remediated |
| NET-001 | `ec2-security-group-opens-SSH-port-to-all` | 1 flagged / 5 checked | 0 flagged / 20 checked | Remediated |
| LOG-001 | `cloudtrail-not-configured` | 1 flagged / 1 checked | 0 flagged / 17 checked | Remediated |
| EC2-002 | `ec2-ebs-volume-not-encrypted` | 1 flagged / 1 checked | 0 flagged / 1 checked | Remediated |
| EC2-002 | `ec2-ebs-default-encryption-disabled` | 1 flagged / 1 checked | 16 flagged / 17 checked | Remediated in `us-east-1`; account-wide residual remains |

## IAM Interpretation

The intentionally vulnerable project identity `cloudsec-lab-admin` appeared nine times in the baseline ScoutSuite dataset and zero times after remediation.

ScoutSuite still reports one full-privilege finding and one no-MFA finding at the account level. Those findings are not attributed to the deleted project identity and are retained as account-level residual risk.

The project therefore does not claim that every IAM issue in the AWS account has been eliminated.

## Regional EBS Encryption Interpretation

The project is deployed and assessed primarily in `us-east-1`.

Direct AWS validation confirms that EBS encryption by default is enabled in `us-east-1`. The post-remediation ScoutSuite scan evaluated 17 Regions and reported the control disabled in 16 other Regions.

This means:

- the project workload and primary Region satisfy EC2-002;
- account-wide EBS encryption-by-default coverage remains incomplete;
- production governance should enable the control across all approved Regions or restrict unused Regions through organizational guardrails.

The baseline ScoutSuite report checked only one item for this rule while the post-remediation report checked 17. The increase from one flagged item to sixteen therefore must not be interpreted as a simple security regression because scanner coverage changed.

## Corroboration

ScoutSuite results align with independent validation:

- the public S3 exposure was removed;
- public SSH exposure was removed;
- the active EBS volume is encrypted;
- a durable customer-managed CloudTrail trail is active;
- the vulnerable project IAM identity was removed.

Prowler and manual AWS CLI/runtime validation independently corroborate these project-level control changes.

## Scanner Collection Limitations

Several AWS APIs returned subscription, opt-in, or account-tier errors for services not used by the lab, including Direct Connect, Redshift, EMR, and Route 53 Domains.

Those collection limitations did not prevent ScoutSuite from assessing the IAM, EC2, S3, and CloudTrail controls mapped to the primary project findings.

## Interpretation

ScoutSuite is used as an independent evidence source, not as the sole measure of security posture.

A finding indicates a configuration condition. It does not by itself prove successful exploitation, credential theft, unauthorized access, persistence, or data exfiltration.
