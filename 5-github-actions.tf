data "tfe_team" "owners" {
  name         = "owners"
  organization = tfe_organization.organization.name
}

resource "tfe_team_token" "github_actions_token" {
  team_id = data.tfe_team.owners.id
}

resource "github_actions_secret" "tfe_secret" {
  repository      = github_repository.repo.name
  secret_name     = "TFE_TOKEN"
  plaintext_value = tfe_team_token.github_actions_token.token
}
