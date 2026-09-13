# Prowler Baseline Assessment

## Assessment Context

Prowler v5.42.0 was used to assess the intentionally insecure AWS baseline in `us-east-1`.

The baseline scan executed 648 checks and produced:

- 107 failed findings
- 94 passed findings
- 0 muted findings

The complete scanner output is retained locally as raw evidence because it contains AWS account identifiers, ARNs, resource identifiers, and other runtime metadata.

`prowler-baseline-summary.csv` contains only the sanitized Prowler findings directly mapped to the project risk register.

## In-Scope Finding Mapping

| Project Finding | Security Issue |
|---|---|
| IAM-001 | Privileged IAM console user with AdministratorAccess and no MFA |
| S3-001 | Publicly accessible S3 object storage |
| NET-001 | SSH exposed to the Internet |
| EC2-001 | IMDSv2 not enforced |
| LOG-001 | No durable multi-Region CloudTrail trail |
| DET-001 | Limited AWS-native external-access analysis |

Prowler findings were not accepted solely because the scanner reported them. Relevant findings were manually validated using AWS CLI queries and controlled connectivity/access tests.

The complete Prowler result set also contains account-level recommendations and findings outside the intentionally constructed lab scope. Those findings are retained for analysis but are not automatically treated as project vulnerabilities.
