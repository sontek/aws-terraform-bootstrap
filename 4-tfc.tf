resource "tfe_organization" "organization" {
  name  = var.tfc_organization_name
  email = var.tfc_organization_owner
}

/* AWS will use this TLS certificate to verify that requests for dynamic
credentials come from Terraform Cloud.*/
data "tls_certificate" "tfc_certificate" {
  url = "https://${var.tfc_hostname}"
}

/* sets up an OIDC provider in AWS with Terraform Cloud's TLS certificate,
the SHA1 fingerprint from the TLS certificate 
*/
resource "aws_iam_openid_connect_provider" "tfc_provider" {
  url            = data.tls_certificate.tfc_certificate.url
  client_id_list = [var.tfc_aws_audience]
  thumbprint_list = [
    data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint
  ]
}

/* Policy to allow TFC to assume the AWS IAM role in our account */
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.tfc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.tfc_hostname}:aud"

      values = [
        "${one(aws_iam_openid_connect_provider.tfc_provider.client_id_list)}"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "${var.tfc_hostname}:sub"

      values = [
        for workspace in var.tfc_workspaces : "organization:${tfe_organization.organization.name}:project:${var.tfc_project_name}:workspace:${workspace}:run_phase:*"
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "tfc-agent" {
  name               = "tfc-agent"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

/* Policy for what the TFC agent is allowed to do */
data "aws_iam_policy_document" "tfc-agent" {
  version = "2012-10-17"

  statement {
    actions   = ["*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "tfc-agent" {
  name        = "tfc-agent-access-policy"
  description = "Access policy for the TFC agent"
  policy      = data.aws_iam_policy_document.tfc-agent.json
}

resource "aws_iam_role_policy_attachment" "tfc-access-attach" {
  role       = aws_iam_role.tfc-agent.name
  policy_arn = aws_iam_policy.tfc-agent.arn
}

resource "tfe_workspace" "workspaces" {
  count        = length(var.tfc_workspaces)
  name         = var.tfc_workspaces[count.index]
  organization = tfe_organization.organization.name

  working_directory = var.tfc_workspaces[count.index]
}

/* These variables tell the agent to use dynamic credentials */
resource "tfe_variable" "tfc-auth" {
  count        = length(var.tfc_workspaces)
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = true
  category     = "env"
  workspace_id = tfe_workspace.workspaces[count.index].id
  description  = "Enable dynamic auth on the TFC agents"
}

resource "tfe_variable" "tfc-role" {
  count        = length(var.tfc_workspaces)
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = aws_iam_role.tfc-agent.arn
  category     = "env"
  workspace_id = tfe_workspace.workspaces[count.index].id
  description  = "Tell TFC what Role to run as"
}