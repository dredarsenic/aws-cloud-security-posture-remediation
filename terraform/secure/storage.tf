# -------------------------------------------------------------------
# Hardened S3 Storage
#
# S3-001 remediation:
# The same bucket used during the insecure baseline is retained so
# that before-and-after validation represents an actual remediation.
#
# The Terraform resource label and bucket prefix retain their original
# baseline names to preserve resource identity and avoid replacing the
# bucket solely for naming purposes.
# -------------------------------------------------------------------

resource "aws_s3_bucket" "public_lab" {
  bucket_prefix = "cloudsec-public-lab-"

  tags = {
    Name = "${local.name_prefix}-secure-s3"
  }
}

# -------------------------------------------------------------------
# Object Ownership
#
# ACL-based access is disabled. Access control is managed using IAM
# and bucket policies.
# -------------------------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "public_lab" {
  bucket = aws_s3_bucket.public_lab.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# -------------------------------------------------------------------
# Block Public Access
#
# All bucket-level S3 public-access protections are enabled.
# -------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "public_lab" {
  bucket = aws_s3_bucket.public_lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------------------------------
# Versioning
# -------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "public_lab" {
  bucket = aws_s3_bucket.public_lab.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------------------------------------------------
# Explicit Server-Side Encryption
#
# S3 already provides automatic encryption, but the secure Terraform
# configuration explicitly codifies encryption at rest.
# -------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "public_lab" {
  bucket = aws_s3_bucket.public_lab.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------------------------------------------
# Harmless Demonstration Object
#
# The object is deliberately retained so that anonymous access can be
# tested again after remediation.
# -------------------------------------------------------------------

resource "aws_s3_object" "demo_file" {
  bucket = aws_s3_bucket.public_lab.id
  key    = "demo-data.txt"

  content = <<-EOF_CONTENT
AWS Cloud Security Posture Remediation Lab

This file contains no real, confidential, customer, or production data.

It exists only to demonstrate secure S3 access-control remediation.
EOF_CONTENT

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  depends_on = [
    aws_s3_bucket_ownership_controls.public_lab,
    aws_s3_bucket_server_side_encryption_configuration.public_lab
  ]
}

# -------------------------------------------------------------------
# TLS-Only Bucket Policy
#
# The insecure baseline policy granted s3:GetObject to Principal "*".
# That public allow statement has been removed.
#
# The replacement policy denies all S3 operations when requests do
# not use TLS.
# -------------------------------------------------------------------

resource "aws_s3_bucket_policy" "secure_transport" {
  bucket = aws_s3_bucket.public_lab.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_lab
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.public_lab.arn,
          "${aws_s3_bucket.public_lab.arn}/*"
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
