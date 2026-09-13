# -------------------------------------------------------------------
# Intentionally Misconfigured S3 Storage
#
# S3-001:
# This bucket deliberately permits unauthenticated read access to a
# harmless demonstration object.
#
# No real, confidential, customer, or production data is stored here.
# -------------------------------------------------------------------

resource "aws_s3_bucket" "public_lab" {
  bucket_prefix = "cloudsec-public-lab-"

  tags = {
    Name = "${local.name_prefix}-public-s3"
  }
}

# -------------------------------------------------------------------
# Public Access Protection
#
# Intentionally disabled at the bucket level so the public-read policy
# can be assessed by ScoutSuite, Prowler, and manual validation.
# -------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "public_lab" {
  bucket = aws_s3_bucket.public_lab.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# -------------------------------------------------------------------
# Versioning
#
# Intentionally not enabled as part of the insecure baseline.
# -------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "public_lab" {
  bucket = aws_s3_bucket.public_lab.id

  versioning_configuration {
    status = "Suspended"
  }
}

# -------------------------------------------------------------------
# Harmless Demonstration Object
# -------------------------------------------------------------------

resource "aws_s3_object" "demo_file" {
  bucket = aws_s3_bucket.public_lab.id
  key    = "demo-data.txt"

  content = <<-EOF_CONTENT
AWS Cloud Security Posture Remediation Lab

This file contains no real, confidential, customer, or production data.

It exists only to demonstrate an intentionally misconfigured public S3 object.
EOF_CONTENT

  content_type = "text/plain"
}

# -------------------------------------------------------------------
# Intentionally Public Bucket Policy
#
# S3-001:
# Anonymous principals can retrieve objects from this bucket.
# -------------------------------------------------------------------

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.public_lab.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_lab
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "IntentionallyPublicReadForSecurityLab"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public_lab.arn}/*"
      }
    ]
  })
}
