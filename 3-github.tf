resource "github_repository" "repo" {
  name        = var.github_repo_name
  description = "Infrastructure Repository"
  visibility  = "private"
  auto_init   = true
  has_issues  = true
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = var.github_default_branch
}

output "repository_id" {
  value = github_repository.repo.id
}
