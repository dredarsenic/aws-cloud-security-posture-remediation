# -------------------------------------------------------------------
# State migration mappings
#
# These mappings preserve resource identity while transitioning from
# insecure Terraform resource labels to secure labels.
# -------------------------------------------------------------------

moved {
  from = aws_security_group.insecure_web
  to   = aws_security_group.secure_web
}

moved {
  from = aws_instance.insecure_web
  to   = aws_instance.secure_web
}

moved {
  from = aws_s3_bucket_policy.public_read
  to   = aws_s3_bucket_policy.secure_transport
}
