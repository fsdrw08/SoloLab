data "terraform_remote_state" "tfstate" {
  backend = "local"
  config = {
    path = "../../../TLS/RootCA/terraform.tfstate"
  }
}

# data "vault_kv_secret_v2" "root_cert" {
#   mount = "kvv2_certs"
#   name  = "sololab_root"
# }

resource "vault_ldap_auth_backend" "ldap" {
  path                 = var.vault_ldap_auth_backend.path
  url                  = var.vault_ldap_auth_backend.url
  starttls             = var.vault_ldap_auth_backend.starttls
  case_sensitive_names = var.vault_ldap_auth_backend.case_sensitive_names
  tls_min_version      = var.vault_ldap_auth_backend.tls_min_version
  tls_max_version      = var.vault_ldap_auth_backend.tls_max_version
  insecure_tls         = var.vault_ldap_auth_backend.insecure_tls
  certificate          = data.terraform_remote_state.tfstate.outputs.root_cert_pem
  binddn               = var.vault_ldap_auth_backend.binddn
  bindpass             = var.vault_ldap_auth_backend.bindpass
  userdn               = var.vault_ldap_auth_backend.userdn
  userattr             = var.vault_ldap_auth_backend.userattr
  userfilter           = var.vault_ldap_auth_backend.userfilter
  upndomain            = var.vault_ldap_auth_backend.upndomain
  discoverdn           = var.vault_ldap_auth_backend.discoverdn
  deny_null_bind       = var.vault_ldap_auth_backend.deny_null_bind
  groupfilter          = var.vault_ldap_auth_backend.groupfilter
  groupdn              = var.vault_ldap_auth_backend.groupdn
  groupattr            = var.vault_ldap_auth_backend.groupattr
  username_as_alias    = var.vault_ldap_auth_backend.username_as_alias
  use_token_groups     = var.vault_ldap_auth_backend.use_token_groups
  disable_remount      = var.vault_ldap_auth_backend.disable_remount
  description          = var.vault_ldap_auth_backend.description
  local                = var.vault_ldap_auth_backend.local

  # Common Token Arguments
  token_ttl               = var.vault_ldap_auth_backend.token_ttl
  token_max_ttl           = var.vault_ldap_auth_backend.token_max_ttl
  token_period            = var.vault_ldap_auth_backend.token_period
  token_policies          = var.vault_ldap_auth_backend.token_policies
  token_bound_cidrs       = var.vault_ldap_auth_backend.token_bound_cidrs
  token_explicit_max_ttl  = var.vault_ldap_auth_backend.token_explicit_max_ttl
  token_no_default_policy = var.vault_ldap_auth_backend.token_no_default_policy
  token_num_uses          = var.vault_ldap_auth_backend.token_num_uses
  token_type              = var.vault_ldap_auth_backend.token_type

}

data "ldap_entries" "users" {
  ou     = var.ldap_vault_entities.users.ou
  filter = var.ldap_vault_entities.users.filter
}

data "ldap_entries" "groups" {
  ou     = var.ldap_vault_entities.groups.ou
  filter = var.ldap_vault_entities.groups.filter
}

# output "groups" {
#   value = data.ldap_entries.groups
# }

# resource "vault_identity_entity" "user" {
#   # for_each = {
#   #   for user in var.ldap_vault_entities.users : user => user
#   # }
#   for_each = {
#     for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).mail[0] => entry
#   }
#   name              = each.key
#   external_policies = true
# }

# resource "vault_identity_entity_alias" "alias" {
#   for_each = {
#     for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).mail[0] => entry
#   }
#   name           = each.key
#   mount_accessor = vault_ldap_auth_backend.ldap.accessor
#   canonical_id   = vault_identity_entity.user[each.key].id
# }

resource "vault_identity_entity" "user" {
  # for_each = {
  #   for user in var.ldap_vault_entities.users : user => user
  # }
  for_each = {
    for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).uid[0] => entry
  }
  name              = jsondecode(each.value.data_json).cn[0]
  external_policies = true
  metadata = {
    email = jsondecode(each.value.data_json).mail[0]
  }

}

resource "vault_identity_entity_alias" "alias" {
  for_each = {
    # for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).mail[0] => entry
    for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).uid[0] => entry
  }
  name           = jsondecode(each.value.data_json).uid[0]
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_entity.user[jsondecode(each.value.data_json).uid[0]].id
}

resource "vault_identity_group" "group" {
  for_each = {
    for entry in data.ldap_entries.groups.entries : jsondecode(entry.data_json).cn[0] => entry
  }
  name              = each.key
  type              = "external"
  external_policies = true
}

resource "vault_identity_group_alias" "alias" {
  for_each = {
    for entry in data.ldap_entries.groups.entries : jsondecode(entry.data_json).cn[0] => entry
  }
  name           = each.key
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.group[each.key].id
}

