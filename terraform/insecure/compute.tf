# -------------------------------------------------------------------
# Amazon Linux 2023 AMI
# -------------------------------------------------------------------

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -------------------------------------------------------------------
# Intentionally Insecure Security Group
#
# NET-001:
# SSH is intentionally exposed to the entire IPv4 internet.
# This configuration exists only inside this controlled lab so that
# cloud security tools can identify and assess the exposure.
# -------------------------------------------------------------------

resource "aws_security_group" "insecure_web" {
  name        = "${local.name_prefix}-insecure-web-sg"
  description = "Intentionally insecure security group for cloud security assessment"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "INTENTIONALLY INSECURE - SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "${local.name_prefix}-insecure-web-sg"
  }
}

# -------------------------------------------------------------------
# Intentionally Insecure EC2 Workload
#
# EC2-001:
# IMDSv2 is not enforced. Tokens are optional, allowing IMDSv1.
#
# No SSH key pair is configured. The security assessment focuses on
# network exposure rather than deliberately weakening authentication.
# -------------------------------------------------------------------

resource "aws_instance" "insecure_web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.insecure_web.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = <<-EOF_USER_DATA
    #!/bin/bash
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
  EOF_USER_DATA

  tags = {
    Name = "${local.name_prefix}-insecure-web"
    Role = "Demo Web Application"
  }
}
