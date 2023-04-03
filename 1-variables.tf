variable "tfc_aws_audience" {
  type        = string
  default     = "aws.workload.identity"
  description = "The audience value to use in run identity tokens"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with AWS"
}

variable "tfc_project_name" {
  type        = string
  default     = "Default Project"
  description = "The project under which a workspace will be created"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_organization_owner" {
  type        = string
  description = "The owner of the TFC organization"
}

variable "tfc_workspaces" {
  type        = list(string)
  description = "The list of TFC workspaces"
}

variable "github_organization" {
  description = "The organization the repositories are owned by"
  type        = string
}

variable "github_repo_name" {
  description = "The name of the git reppository we'll create for managing infra"
  type        = string
}

variable "github_default_branch" {
  description = "The default branch to utilize"
  type        = string
  default     = "main"
}

variable "aws_root_account_id" {
  description = "The AWS root account we want to apply these changes to"
  type        = string
}