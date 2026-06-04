resource "tfe_organization" "org" {
  for_each = {
    for org in var.organizations : org.iac_id => org
  }
  name                                = each.value.name
  email                               = each.value.email
  owners_team_saml_role_id            = each.value.owners_team_saml_role_id
  speculative_plan_management_enabled = each.value.speculative_plan_management_enabled
}

locals {
  teams = flatten([
    for org in var.organizations : [
      for team in org.teams : merge(
        team,
        { org_iac_id = org.iac_id }
      )
    ]
  ])
}

resource "tfe_team" "team" {
  depends_on = [
    tfe_organization.org
  ]
  for_each = {
    for team in local.teams : team.iac_id => team
  }
  name                          = each.value.name
  organization                  = tfe_organization.org[each.value.org_iac_id].name
  allow_member_token_management = each.value.allow_member_token_management
  organization_access {
    read_workspaces            = each.value.organization_access.read_workspaces
    read_projects              = each.value.organization_access.read_projects
    manage_policies            = each.value.organization_access.manage_policies
    manage_policy_overrides    = each.value.organization_access.manage_policy_overrides
    manage_workspaces          = each.value.organization_access.manage_workspaces
    manage_vcs_settings        = each.value.organization_access.manage_vcs_settings
    manage_providers           = each.value.organization_access.manage_providers
    manage_modules             = each.value.organization_access.manage_modules
    manage_run_tasks           = each.value.organization_access.manage_run_tasks
    manage_projects            = each.value.organization_access.manage_projects
    manage_membership          = each.value.organization_access.manage_membership
    manage_organization_access = each.value.organization_access.manage_organization_access
    access_secret_teams        = each.value.organization_access.access_secret_teams
    manage_agent_pools         = each.value.organization_access.manage_agent_pools
  }
}

locals {
  team_members = flatten([
    for team in local.teams : [
      for member in team.members : {
        username    = member,
        team_iac_id = team.iac_id
      }
    ]
  ])
}

resource "tfe_team_member" "team_member" {
  depends_on = [
    tfe_team.team
  ]
  for_each = {
    for team_member in local.team_members : "${team_member.team_iac_id}-${team_member.username}" => team_member
  }
  team_id  = tfe_team.team[each.value.team_iac_id].id
  username = each.value.username
}

locals {
  workspaces = flatten([
    for org in var.organizations : [
      for workspace in org.workspaces : merge(
        workspace,
        { org_iac_id = org.iac_id }
      )
    ]
  ])
}

resource "tfe_workspace" "workspace" {
  depends_on = [
    tfe_organization.org
  ]
  for_each = {
    for workspace in local.workspaces : workspace.iac_id => workspace
  }
  name                  = each.value.name
  organization          = tfe_organization.org[each.value.org_iac_id].name
  file_triggers_enabled = each.value.file_triggers_enabled
  force_delete          = true
}

resource "tfe_workspace_settings" "workspace_settings" {
  for_each = {
    for workspace in local.workspaces : workspace.iac_id => workspace
  }
  workspace_id   = tfe_workspace.workspace[each.value.iac_id].id
  execution_mode = each.value.execution_mode
  agent_pool_id  = each.value.agent_pool_id
}

locals {
  team_access = flatten([
    for workspace in local.workspaces : [
      for team_access in workspace.team_access : merge(
        { workspace_iac_id = workspace.iac_id },
        team_access
      )
    ]
  ])
}

# resource "tfe_team_access" "team_access" {
#   depends_on = [
#     tfe_workspace.workspace,
#     tfe_team.team
#   ]
#   for_each = {
#     for team in local.team_access : "${team.workspace_iac_id}-${team.team_iac_id}" => team
#   }

#   workspace_id = tfe_workspace.workspace[each.value.workspace_iac_id].id
#   team_id      = tfe_team.team[each.value.team_iac_id].id
#   access       = each.value.access
#   dynamic "permissions" {
#     for_each = each.value.permissions == null ? [] : [""]
#     content {
#       runs              = each.value.permissions.runs
#       variables         = each.value.permissions.variables
#       state_versions    = each.value.permissions.state_versions
#       sentinel_mocks    = each.value.permissions.sentinel_mocks
#       workspace_locking = each.value.permissions.workspace_locking
#       run_tasks         = each.value.permissions.run_tasks
#     }
#   }
# }
