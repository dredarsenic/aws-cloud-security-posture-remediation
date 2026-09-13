# ScoutSuite Before vs After Security Comparison

Both assessments were performed with **ScoutSuite 5.14.0**.

The comparison focuses on controls mapped to the project's risk register. Account-wide findings that cannot be tied to the Terraform-managed workload are retained as residual risks rather than presented as failures of the project remediation.

## Control Comparison

| Finding | ScoutSuite Rule | Baseline | Post-Remediation | Assessment |
|---|---|---|---|---|
| IAM-001 | `iam-managed-policy-allows-full-privileges` | 1 / 24 flagged | 1 / 28 flagged | Project identity removed; unrelated account-level finding remains |
| IAM-001 | `iam-user-without-mfa` | 2 / 3 flagged | 1 / 2 flagged | Project identity removed; unrelated account-level finding remains |
| S3-001 | `s3-bucket-world-Get-policy` | 1 / 1 flagged | 0 / 4 flagged | Remediated |
| NET-001 | `ec2-security-group-opens-SSH-port-to-all` | 1 / 5 flagged | 0 / 20 flagged | Remediated |
| LOG-001 | `cloudtrail-not-configured` | 1 / 1 flagged | 0 / 17 flagged | Remediated |
| EC2-002 | `ec2-ebs-volume-not-encrypted` | 1 / 1 flagged | 0 / 1 flagged | Remediated |
| EC2-002 | `ec2-ebs-default-encryption-disabled` | 1 / 1 flagged | 16 / 17 flagged | `us-east-1` remediated; other Regions remain residual risk |

Numbers are shown as `flagged / checked`.

## Identity Evidence

| Identity | Baseline Occurrences | Post-Remediation Occurrences | Interpretation |
|---|---:|---:|---|
| `cloudsec-lab-admin` | 9 | 0 | Intentionally vulnerable project identity removed |
| `scoutsuite-lab-user` | 7 | 7 | Existing account identity remains outside this project's Terraform scope |
| `aharcel` | 10 | 10 | Existing account identity remains outside this project's Terraform scope |

Occurrence counts indicate presence in the ScoutSuite dataset. They are not equivalent to a count of security findings.

## Public S3 Exposure

**Before:** ScoutSuite flagged `s3-bucket-world-Get-policy`, confirming that object-read access was authorized to all principals.

**After:** The rule reports zero flagged items across four checked buckets.

Manual anonymous-access testing independently changed from HTTP `200` to HTTP `403`.

## Internet-Exposed SSH

**Before:** ScoutSuite flagged a security group exposing TCP/22 to all source addresses.

**After:** `ec2-security-group-opens-SSH-port-to-all` reports zero flagged items across twenty checked security-group evaluations.

Manual network testing independently confirmed that public TCP/22 was no longer reachable.

## Durable Audit Logging

**Before:** ScoutSuite reported `cloudtrail-not-configured`.

**After:** The rule reports zero flagged items.

Manual validation independently confirms that the Terraform-managed CloudTrail trail is multi-Region, actively logging, includes global service events, and has log-file validation enabled.

## EBS Volume Encryption

**Before:** ScoutSuite identified the project workload EBS volume as unencrypted.

**After:** `ec2-ebs-volume-not-encrypted` reports zero flagged items for the active volume.

Prowler and AWS CLI validation independently confirm the active project volume is encrypted.

## EBS Encryption by Default

The post-remediation scan reports sixteen of seventeen Regions with EBS encryption by default disabled.

Direct AWS validation confirms:

- `us-east-1`: enabled;
- sixteen other queried Regions: disabled.

The project workload is deployed in `us-east-1`, so the project-region control is remediated. Account-wide enforcement remains a residual governance issue.

The baseline report checked one item for this rule, while the post-remediation report checked seventeen. Because scanner coverage changed, the flagged-item count must not be treated as a direct before/after deterioration metric.

## IAM

The baseline intentionally included `cloudsec-lab-admin`, a console-enabled project user with AdministratorAccess and no MFA.

That identity no longer appears in the post-remediation ScoutSuite dataset.

ScoutSuite still reports one full-privilege finding and one no-MFA finding at the account level. Those residual findings are not attributed to the deleted project identity and are not silently modified by this project.

## Assessment Limitations

ScoutSuite encountered subscription, opt-in, or account-tier collection errors for several AWS services not used by the lab.

The IAM, EC2, S3, and CloudTrail controls used in this comparison were successfully collected and evaluated.

## Conclusion

ScoutSuite independently corroborates the remediation of the primary project attack surfaces:

- public S3 read access removed;
- public SSH exposure removed;
- workload EBS encryption enabled;
- durable CloudTrail logging established;
- intentionally vulnerable project IAM identity removed.

The assessment also identifies residual account-wide controls that remain outside the project's immediate workload scope, particularly IAM governance and multi-Region EBS encryption-by-default enforcement.
