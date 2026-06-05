locals {
  password_list = flatten([
    for user in var.users : [
      user.iac_id
    ]
    if user.password == null
  ])
}

resource "random_password" "password" {
  for_each = {
    for user in local.password_list : user => user
  }
  length  = 10
  special = false
}

resource "gitea_user" "user" {
  depends_on = [
    random_password.password
  ]
  for_each = {
    for user in var.users : user.iac_id => user
  }
  email                     = each.value.email
  login_name                = each.value.login_name
  password                  = each.value.password != null ? each.value.password : random_password.password[each.value.iac_id].result
  username                  = each.value.username
  active                    = each.value.active
  admin                     = each.value.admin
  allow_create_organization = each.value.allow_create_organization
  allow_git_hook            = each.value.allow_git_hook
  allow_import_local        = each.value.allow_import_local
  description               = each.value.description
  force_password_change     = each.value.force_password_change
  full_name                 = each.value.full_name
  location                  = each.value.location
  max_repo_creation         = each.value.max_repo_creation
  must_change_password      = each.value.must_change_password
  prohibit_login            = each.value.prohibit_login
  restricted                = each.value.restricted
  send_notification         = each.value.send_notification
  visibility                = each.value.visibility
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for user in var.users : user.login_name => user
  }
  mount = "kvv2_gitea"
  name  = "user-${each.value.login_name}"
  data_json_wo = jsonencode(
    {
      username = each.value.login_name
      password = each.value.password != null ? each.value.password : random_password.password[each.value.iac_id].result
    }
  )
  data_json_wo_version = tonumber(each.value.password_version)
  delete_all_versions  = true
}
