resource "tfe_organization" "org" {
  for_each = {
    for org in var.organizations : org.iac_id => org
  }
  name  = each.value.name
  email = each.value.email
}

resource "tfe_workspace" "workspace" {
  depends_on = [
    tfe_organization.org
  ]
  for_each = {
    for workspace in var.workspaces : workspace.iac_id => workspace
  }
  name         = each.value.name
  organization = each.value.organization
  force_delete = true
}

locals {
  workspace_iac_id_mapping = {
    for workspace in var.workspaces :
    workspace.name => workspace.iac_id
  }
}

resource "tfe_workspace_settings" "workspace_settings" {
  for_each = {
    for workspace in var.workspaces : workspace.iac_id => workspace
  }
  workspace_id   = tfe_workspace.workspace[lookup(local.workspace_iac_id_mapping, each.value.name)].id
  execution_mode = "local"
  agent_pool_id  = ""
}
