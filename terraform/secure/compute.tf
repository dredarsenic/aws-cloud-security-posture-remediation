# -------------------------------------------------------------------
# Amazon Linux 2023 AMI
# -------------------------------------------------------------------

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -------------------------------------------------------------------
# Hardened Web Security Group
#
# NET-001 remediation:
# Public SSH access has been removed.
#
# TCP/80 remains public because this instance represents an
# intentionally Internet-facing web application.
# -------------------------------------------------------------------

resource "aws_security_group" "secure_web" {
  name        = "${local.name_prefix}-secure-web-sg"
  description = "Security group for hardened cloud security lab workload"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "Public HTTP application traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-secure-web-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------
# Hardened EC2 Workload
#
# EC2-001:
# IMDSv2 is required.
#
# EC2-002:
# The root EBS volume is encrypted.
#
# NET-001:
# No SSH key pair or public SSH rule is configured. Administrative
# access is provided through AWS Systems Manager Session Manager.
# -------------------------------------------------------------------

resource "aws_instance" "secure_web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.secure_web.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  user_data = <<-EOF_USER_DATA
    #!/bin/bash
    set -e

    dnf install -y nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
      <head>
        <title>CloudSec Lab</title>
      </head>
      <body>
        <h1>AWS Cloud Security Posture Remediation Lab</h1>
        <p>This is a harmless test workload used for defensive cloud security assessment.</p>
      </body>
    </html>
    HTML

    systemctl enable nginx
    systemctl start nginx

    systemctl enable amazon-ssm-agent || true
    systemctl start amazon-ssm-agent || true
  EOF_USER_DATA

  tags = {
    Name = "${local.name_prefix}-secure-web"
    Role = "Demo Web Application"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------
# Regional EBS Encryption Default
#
# EC2-002 defense-in-depth:
# New EBS volumes created in this Region are encrypted by default.
# This does not retroactively encrypt existing volumes.
# -------------------------------------------------------------------

resource "aws_ebs_encryption_by_default" "secure" {
  enabled = true
}
