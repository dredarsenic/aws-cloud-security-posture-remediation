# -------------------------------------------------------------------
# AWS-Native Security Analysis
#
# DET-001 partial remediation:
#
# IAM Access Analyzer is enabled to identify resources shared with
# external principals.
#
# GuardDuty and Security Hub are intentionally not represented as
# enabled because the assessed lab account returned service
# subscription errors during baseline validation.
#
# Those services remain documented as residual controls that should
# be enabled where the account supports them.
# -------------------------------------------------------------------

resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "${local.name_prefix}-account-access-analyzer"
  type          = "ACCOUNT"

  tags = {
    Name = "${local.name_prefix}-account-access-analyzer"
    Role = "External Access Analysis"
  }
}
