resource "gitea_org" "org" {
  for_each = {
    for org in var.organizations : org.iac_id => org
  }
  name                          = each.value.name
  description                   = each.value.description
  full_name                     = each.value.full_name
  location                      = each.value.location
  repo_admin_change_team_access = each.value.repo_admin_change_team_access
  visibility                    = each.value.visibility
  website                       = each.value.website
}

locals {
  teams = flatten([
    for org in var.organizations : [
      for team in org.teams : merge(
        team,
        { org_iac_id = org.iac_id }
      )
    ]
    if org.teams != null
  ])
}

resource "gitea_team" "team" {
  depends_on = [
    gitea_org.org
  ]
  for_each = {
    for team in local.teams : team.iac_id => team
  }
  organisation             = gitea_org.org[each.value.org_iac_id].name
  name                     = each.value.name
  description              = each.value.description
  include_all_repositories = each.value.include_all_repositories
  permission               = each.value.permission
  repositories             = each.value.repositories
  units                    = each.value.units
}

resource "gitea_team_members" "team_member" {
  depends_on = [
    gitea_team.team
  ]
  for_each = {
    for team in local.teams : team.iac_id => team
  }
  team_id = gitea_team.team[each.value.iac_id].id
  members = each.value.members
}

locals {
  repos = flatten([
    for org in var.organizations : [
      for repo in org.repositories : merge(
        repo,
        { org_iac_id = org.iac_id }
      )
    ]
    if org.repositories != null
  ])
}

resource "gitea_repository" "repository" {
  depends_on = [
    gitea_org.org
  ]
  for_each = {
    for repo in local.repos : repo.iac_id => repo
  }
  username                        = gitea_org.org[each.value.org_iac_id].name
  name                            = each.value.name
  allow_manual_merge              = each.value.allow_manual_merge
  allow_merge_commits             = each.value.allow_merge_commits
  allow_rebase                    = each.value.allow_rebase
  allow_rebase_explicit           = each.value.allow_rebase_explicit
  allow_squash_merge              = each.value.allow_squash_merge
  archive_on_destroy              = each.value.archive_on_destroy
  archived                        = each.value.archived
  auto_init                       = each.value.auto_init
  autodetect_manual_merge         = each.value.autodetect_manual_merge
  default_branch                  = each.value.default_branch
  description                     = each.value.description
  gitignores                      = each.value.gitignores
  has_issues                      = each.value.has_issues
  has_projects                    = each.value.has_projects
  has_pull_requests               = each.value.has_pull_requests
  has_wiki                        = each.value.has_wiki
  ignore_whitespace_conflicts     = each.value.ignore_whitespace_conflicts
  issue_labels                    = each.value.issue_labels
  license                         = each.value.license
  migration_clone_address         = each.value.migration_clone_address
  migration_clone_addresse        = each.value.migration_clone_addresse
  migration_issue_labels          = each.value.migration_issue_labels
  migration_lfs                   = each.value.migration_lfs
  migration_lfs_endpoint          = each.value.migration_lfs_endpoint
  migration_milestones            = each.value.migration_milestones
  migration_mirror_interval       = each.value.migration_mirror_interval
  migration_releases              = each.value.migration_releases
  migration_service               = each.value.migration_service
  migration_service_auth_password = each.value.migration_service_auth_password
  migration_service_auth_token    = each.value.migration_service_auth_token
  migration_service_auth_username = each.value.migration_service_auth_username
  mirror                          = each.value.mirror
  private                         = each.value.private
  readme                          = each.value.readme
  repo_template                   = each.value.repo_template
  website                         = each.value.website
}

locals {
  webhooks = flatten([
    for org in var.organizations : [
      for repo in org.repositories : [
        for webhook in repo.webhooks : merge(
          webhook,
          {
            org_iac_id  = org.iac_id
            repo_iac_id = repo.iac_id
          }
        )
      ]
      if repo.webhooks != null
    ]
    if org.repositories != null
  ])
  vault_kvv2_secret_list = flatten([
    for org in var.organizations : [
      for repo in org.repositories : [
        for webhook in repo.webhooks : {
          iac_id = webhook.iac_id
          mount  = webhook.secret.vault_kvv2.mount
          name   = webhook.secret.vault_kvv2.name
        }
        if webhook.secret.vault_kvv2 != null
      ]
      if repo.webhooks != null
    ]
    if org.repositories != null
  ])
}

data "vault_kv_secret_v2" "secret" {
  for_each = local.vault_kvv2_secret_list == null ? null : {
    for vault_kvv2_secret in local.vault_kvv2_secret_list : vault_kvv2_secret.iac_id => vault_kvv2_secret
  }
  mount = each.value.mount
  name  = each.value.name
}

resource "gitea_repository_webhook" "webhook" {
  depends_on = [
    gitea_repository.repository
  ]
  for_each = {
    for webhook in local.webhooks : webhook.iac_id => webhook
  }
  username             = gitea_org.org[each.value.org_iac_id].name
  name                 = gitea_repository.repository[each.value.repo_iac_id].name
  active               = each.value.active
  branch_filter        = each.value.branch_filter
  content_type         = each.value.content_type
  events               = each.value.events
  type                 = each.value.type
  url                  = each.value.url
  authorization_header = each.value.authorization_header
  secret               = each.value.secret.plaintext != null ? each.value.secret.plaintext : data.vault_kv_secret_v2.secret[each.value.iac_id].data[each.value.secret.vault_kvv2.key]
}