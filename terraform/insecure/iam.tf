# -------------------------------------------------------------------
# Intentionally Overprivileged IAM Identity
#
# IAM-001:
# Simulates a human IAM user with console access,
# AdministratorAccess, and no MFA.
#
# No programmatic access keys are created.
# -------------------------------------------------------------------

resource "aws_iam_user" "insecure_admin" {
  name          = "cloudsec-lab-admin"
  path          = "/lab/"
  force_destroy = true

  tags = {
    Name = "cloudsec-lab-admin"
    Role = "Simulated Privileged Administrator"
  }
}

resource "aws_iam_user_policy_attachment" "insecure_admin_administrator" {
  user       = aws_iam_user.insecure_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_login_profile" "insecure_admin" {
  user                    = aws_iam_user.insecure_admin.name
  pgp_key                 = trimspace(file("${path.module}/iam-lab-public-key.b64"))
  password_length         = 32
  password_reset_required = false
}
