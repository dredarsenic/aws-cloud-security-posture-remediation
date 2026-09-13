# Prowler Post-Remediation Assessment

Prowler 5.42.0 was executed after the Terraform security remediation using the same scanner version and AWS Region as the insecure baseline assessment.

The raw Prowler output is retained locally under `../raw/` and excluded from version control because it contains AWS account IDs, ARNs, public IP information, resource IDs, and other runtime metadata.

Only sanitized project-relevant results are published here.

## Project Control Results

| Project Finding | Prowler Control | Result |
|---|---|---|
| IAM-001 | `iam_user_administrator_access_policy` | Project identity removed |
| IAM-001 | `iam_user_mfa_enabled_console_access` | Project identity removed |
| S3-001 | `s3_bucket_public_access` | PASS |
| S3-001 | `s3_bucket_level_public_access_block` | PASS |
| NET-001 | `ec2_instance_port_ssh_exposed_to_internet` | PASS |
| NET-001 | `ec2_securitygroup_allow_ingress_from_internet_to_tcp_port_22` | PASS |
| EC2-001 | `ec2_instance_imdsv2_enabled` | PASS |
| EC2-002 | `ec2_ebs_volume_encryption` | PASS |
| EC2-002 | `ec2_ebs_default_encryption` | PASS |
| LOG-001 | `cloudtrail_multi_region_enabled` | PASS |
| DET-001 | `accessanalyzer_enabled` | PASS |

## IAM Interpretation

The intentionally vulnerable project identity `cloudsec-lab-admin` was removed during remediation. Therefore its IAM findings disappear rather than transition to a PASS row.

Prowler still reports account-level IAM findings for identities unrelated to the Terraform project. Those findings are not presented as failures of the project remediation and were not modified without establishing separate ownership and scope.

This distinction prevents account-wide scanner results from being incorrectly attributed to the controlled workload.

## Terminated EC2 Resource

The post-remediation scan also observed the previous insecure EC2 instance in the AWS API as a recently terminated resource.

The active `secure-lab` EC2 workload independently passed both the SSH-exposure and IMDSv2 checks. Manual AWS validation also confirmed that the previous workload is terminated and the hardened workload is running.

## Overall Scan Context

The post-remediation scan executed 648 checks with Prowler 5.42.0.

Overall account results improved, but account-wide PASS/FAIL totals are not used as the primary measure of project success because:

- the remediation created additional AWS security resources;
- Prowler evaluates resources outside this Terraform project;
- unrelated account-level findings remain;
- resource counts differ between baseline and post-remediation scans.

The project's success criteria are therefore based on the mapped controls listed above and direct manual validation.
