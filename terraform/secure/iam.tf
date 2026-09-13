# -------------------------------------------------------------------
# EC2 Administrative Access
#
# IAM-001 / NET-001 remediation:
# The insecure baseline provisioned a long-lived privileged human IAM
# user and exposed SSH to the Internet.
#
# The secure workload does not provision privileged human IAM users.
# Administrative access to the EC2 workload uses AWS Systems Manager
# Session Manager with a narrowly scoped EC2 service role.
# -------------------------------------------------------------------

resource "aws_iam_role" "ec2_ssm" {
  name = "${local.name_prefix}-ec2-ssm-role"
  path = "/lab/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-ssm-role"
    Role = "EC2 Systems Manager Access"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${local.name_prefix}-ec2-ssm-profile"
  path = "/lab/"
  role = aws_iam_role.ec2_ssm.name
}
