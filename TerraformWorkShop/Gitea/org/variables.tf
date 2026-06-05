variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = optional(bool, false)
    token           = optional(string, null)
  })
}

variable "prov_gitea" {
  type = object({
    base_url    = string
    cacert_file = optional(string, null)
    insecure    = bool
    credential = optional(
      map(object({
        plaintext = optional(string, null)
        vault_kvv2 = optional(
          object({
            mount = string
            name  = string
            key   = string
          }),
          null
        )
      })),
      null
    )
  })
}

variable "organizations" {
  type = list(object({
    iac_id                        = string
    name                          = string
    description                   = optional(string, null)
    full_name                     = optional(string, null)
    location                      = optional(string, null)
    repo_admin_change_team_access = optional(bool, false)
    visibility                    = optional(string, "public")
    website                       = optional(string, null)
    repositories = optional(list(object({
      iac_id                          = string
      name                            = string
      allow_manual_merge              = optional(bool, null)
      allow_merge_commits             = optional(bool, null)
      allow_rebase                    = optional(bool, null)
      allow_rebase_explicit           = optional(bool, null)
      allow_squash_merge              = optional(bool, null)
      archive_on_destroy              = optional(bool, null) # Set to ' true ' to archive the repository instead of deleting on destroy.
      archived                        = optional(bool, null)
      auto_init                       = optional(bool, null) # Flag if the repository should be initiated with the configured values
      autodetect_manual_merge         = optional(bool, null)
      default_branch                  = optional(string, null) # The default branch of the repository.Defaults to main
      description                     = optional(string, null) # The description of the repository.
      gitignores                      = optional(string, null) # A specific gitignore that should be commited to the repositoryon creation if auto_init is set to true Need to exist in the gitea instance
      has_issues                      = optional(bool, null)   # A flag if the repository should have issue management enabled or not.
      has_projects                    = optional(bool, null)   # A flag if the repository should have the native project management enabled or not.
      has_pull_requests               = optional(bool, null)   # A flag if the repository should acceppt pull requests or not.
      has_wiki                        = optional(bool, null)   # A flag if the repository should have the native wiki enabled or not.
      ignore_whitespace_conflicts     = optional(bool, null)
      issue_labels                    = optional(string, null) # The Issue Label configuration to be used in this repository.Need to exist in the gitea instance
      license                         = optional(string, null) # The license under which the source code of this repository should be.Need to exist in the gitea instance
      migration_clone_address         = optional(string, null)
      migration_clone_addresse        = optional(string, null) # DEPRECATED in favor of migration_clone_address
      migration_issue_labels          = optional(bool, null)
      migration_lfs                   = optional(bool, null)
      migration_lfs_endpoint          = optional(string, null)
      migration_milestones            = optional(bool, null)
      migration_mirror_interval       = optional(string, null) # valid time units are ' h ', ' m ', ' s '.0 to disable automatic sync
      migration_releases              = optional(bool, null)
      migration_service               = optional(string, null) # git / github / gitlab / gitea / gogs
      migration_service_auth_password = optional(string, null) # sensitive
      migration_service_auth_token    = optional(string, null) # sensitive
      migration_service_auth_username = optional(string, null)
      mirror                          = optional(bool, null)
      private                         = optional(bool, null) # Flag if the repository should be private or not.
      readme                          = optional(string, null)
      repo_template                   = optional(bool, null)
      website                         = optional(string, null) # A link to a website with more information.
    })), null)
  }))
}