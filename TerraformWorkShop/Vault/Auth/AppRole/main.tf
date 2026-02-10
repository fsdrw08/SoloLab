resource "vault_auth_backend" "backend" {
  path = "approle"
  type = "approle"
}

# ref: https://github.com/Mastercard/mangos/blob/f5d5530f43c82a959fe631811a862546c80fb366/mkosi.images/terraform/share/terraform/consul-connect.tf#L143
# https://developer.hashicorp.com/vault/docs/auth/approle#configuration
resource "vault_approle_auth_backend_role" "role" {
  for_each = {
    for role in var.approles : role.role_name => role
  }
  backend                 = vault_auth_backend.backend.path
  role_name               = each.value.role_name
  role_id                 = each.value.role_id
  bind_secret_id          = each.value.bind_secret_id
  secret_id_bound_cidrs   = each.value.secret_id_bound_cidrs
  secret_id_num_uses      = each.value.secret_id_num_uses
  secret_id_ttl           = each.value.secret_id_ttl
  token_ttl               = each.value.token_ttl
  token_max_ttl           = each.value.token_max_ttl
  token_period            = each.value.token_period
  token_policies          = each.value.token_policies
  token_bound_cidrs       = each.value.token_bound_cidrs
  token_explicit_max_ttl  = each.value.token_explicit_max_ttl
  token_no_default_policy = each.value.token_no_default_policy
  token_num_uses          = each.value.token_num_uses
  token_type              = each.value.token_type
  alias_metadata          = each.value.alias_metadata
}

ephemeral "vault_approle_auth_backend_role_secret_id" "secret_id" {
  for_each = {
    for role in var.approles : role.role_name => role
  }
  backend   = vault_auth_backend.backend.path
  mount_id  = vault_auth_backend.backend.id
  role_name = vault_approle_auth_backend_role.role[each.key].role_name
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for role in var.approles : role.role_name => role
  }
  mount               = var.vault_secret_backend
  name                = "approle-${replace(each.value.role_name, "-", "_")}"
  delete_all_versions = true
  data_json_wo = jsonencode(
    {
      role_id   = vault_approle_auth_backend_role.role[each.key].role_id
      secret_id = ephemeral.vault_approle_auth_backend_role_secret_id.secret_id[each.key].secret_id
    }
  )
  data_json_wo_version = each.value.secret_version
}