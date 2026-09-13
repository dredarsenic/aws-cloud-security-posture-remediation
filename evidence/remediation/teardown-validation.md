# Lab Teardown Validation

**Validation date:** 2026-09-13

The temporary AWS infrastructure used for the cloud security assessment and remediation project was destroyed after all required assessment evidence had been collected.

## Terraform Result

```text
Apply complete! Resources: 0 added, 0 changed, 23 destroyed.
```

## Post-Destroy Validation

| Validation | Result |
|---|---|
| Terraform-managed lab resources remaining | None |
| Project VPC | Removed |
| Project EC2 workload | Terminated |
| Project CloudTrail trail | Removed |
| EBS encryption by default (`us-east-1`) | Preserved and enabled |
| IAM Access Analyzer | Preserved and active |

## Preserved Account-Level Controls

Two account-level controls were intentionally excluded from the final destruction operation:

- EBS encryption by default in `us-east-1`;
- IAM Access Analyzer.

They were removed from the project's Terraform state before teardown so the temporary lab could be destroyed without weakening the account-level security posture.

## State Preservation

A pre-destroy Terraform state backup was retained outside the Git repository with restricted local filesystem permissions.

No raw Terraform state, AWS account identifiers, resource identifiers, scanner raw output, or credentials are included in this published teardown evidence.

## Lifecycle Outcome

The project lifecycle is complete:

```text
Provision
   |
Assess
   |
Validate Risk
   |
Remediate as Code
   |
Reassess
   |
Validate
   |
Document
   |
Destroy Temporary Infrastructure
```
