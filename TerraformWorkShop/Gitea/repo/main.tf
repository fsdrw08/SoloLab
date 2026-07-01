import {
  id = "standalone-lab/sololab"
  to = gitea_repository.repository["93b6d451"]
}

resource "gitea_repository" "repository" {
  for_each = {
    for repo in var.repositories : repo.iac_id => repo
  }
  username                        = each.value.org_name
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
    for repo in var.repositories : [
      for webhook in repo.webhooks : merge(
        webhook,
        {
          repo_iac_id = repo.iac_id
        }
      )
    ]
    if repo.webhooks != null
  ])
  vault_kvv2_secret_list = flatten([
    for repo in var.repositories : [
      for webhook in repo.webhooks : {
        iac_id = webhook.iac_id
        mount  = webhook.secret.vault_kvv2.mount
        name   = webhook.secret.vault_kvv2.name
      }
      if webhook.secret.vault_kvv2 != null
    ]
    if repo.webhooks != null
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
  owner                = gitea_repository.repository[each.value.repo_iac_id].username
  repository           = gitea_repository.repository[each.value.repo_iac_id].name
  active               = each.value.active
  branch_filter        = each.value.branch_filter
  events               = each.value.events
  type                 = each.value.type
  authorization_header = each.value.authorization_header
  config = {
    url          = each.value.url
    content_type = each.value.content_type
    secret       = each.value.secret.plaintext != null ? each.value.secret.plaintext : data.vault_kv_secret_v2.secret[each.value.iac_id].data[each.value.secret.vault_kvv2.key]
  }
}