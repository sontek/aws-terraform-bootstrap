terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.41.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.58.0"
    }

    github = {
      source  = "integrations/github"
      version = "5.18.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Root account, all other accounts should be provisioned
  # via pull requests
  allowed_account_ids = [var.aws_root_account_id]
}

provider "github" {
  owner = var.github_organization
}
