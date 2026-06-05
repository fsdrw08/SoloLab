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