# -------------------------------------------------------------------
# Durable AWS Audit Logging
#
# LOG-001 remediation:
# The insecure baseline relied only on CloudTrail Event History.
#
# The secure architecture creates a customer-managed, multi-Region
# CloudTrail trail with durable S3 storage and log-file validation.
# -------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  cloudtrail_name = "${local.name_prefix}-audit-trail"

  cloudtrail_arn = format(
    "arn:%s:cloudtrail:%s:%s:trail/%s",
    data.aws_partition.current.partition,
    var.aws_region,
    data.aws_caller_identity.current.account_id,
    local.cloudtrail_name
  )
}

# -------------------------------------------------------------------
# Dedicated CloudTrail Log Archive
#
# force_destroy is enabled because this is a disposable security lab.
# A production logging archive would normally use stronger deletion
# protections, longer retention, and potentially a separate account.
# -------------------------------------------------------------------

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "cloudsec-cloudtrail-"
  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-cloudtrail-logs"
    Role = "Security Audit Log Archive"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------------------------------------------
# CloudTrail Bucket Policy
#
# CloudTrail may verify the bucket ACL and write audit logs only to
# the account-specific AWSLogs prefix.
#
# All non-TLS S3 requests are explicitly denied.
# -------------------------------------------------------------------

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  depends_on = [
    aws_s3_bucket_public_access_block.cloudtrail_logs
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn

        Condition = {
          StringEquals = {
            "aws:SourceArn" = local.cloudtrail_arn
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = local.cloudtrail_arn
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.cloudtrail_logs.arn,
          "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# -------------------------------------------------------------------
# Multi-Region CloudTrail
# -------------------------------------------------------------------

resource "aws_cloudtrail" "audit" {
  name                          = local.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs
  ]

  tags = {
    Name = local.cloudtrail_name
    Role = "Security Audit Trail"
  }
}

# -------------------------------------------------------------------
# CloudTrail Log Retention
#
# Audit logs are retained for 365 days to demonstrate a defined
# forensic and compliance retention policy.
#
# Production retention periods should be aligned with legal,
# regulatory, contractual, and organizational requirements.
# -------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  depends_on = [
    aws_s3_bucket_versioning.cloudtrail_logs
  ]

  rule {
    id     = "cloudtrail-log-retention"
    status = "Enabled"

    filter {}

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
