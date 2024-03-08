data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

resource "vault_ldap_auth_backend" "ldap" {
  url                  = var.vault_ldap_auth_backend.url
  starttls             = var.vault_ldap_auth_backend.starttls
  case_sensitive_names = var.vault_ldap_auth_backend.case_sensitive_names
  tls_min_version      = var.vault_ldap_auth_backend.tls_min_version
  tls_max_version      = var.vault_ldap_auth_backend.tls_max_version
  insecure_tls         = var.vault_ldap_auth_backend.insecure_tls
  certificate          = data.terraform_remote_state.root_ca.outputs.root_cert_pem
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
  path                 = var.vault_ldap_auth_backend.path
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

resource "vault_identity_entity" "user" {
  # for_each = {
  #   for user in var.ldap_vault_entities.users : user => user
  # }
  for_each = {
    for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).uid[0] => entry
  }
  name              = each.key
  external_policies = true
}

resource "vault_identity_entity_alias" "alias" {
  for_each = {
    for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).uid[0] => entry
  }
  name           = each.key
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_entity.user[each.key].id
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


# output "ldap_entries" {
#   # value = data.ldap_entries.groups.entries
#   value = [
#     for entry in data.ldap_entries.groups.entries : jsondecode(entry.data_json).cn[0]
#   ]
# }

# module "ldap_mgmt" {
#   source = "../modules/ldap-mgmt"

#   vault_ldap_auth = {
#     path         = "ldap"
#     url          = "ldaps://lldap.service.consul"
#     insecure_tls = false
#     certificate  = data.terraform_remote_state.root_ca.outputs.root_cert_pem
#     # freeipa
#     # binddn       = "uid=system,cn=sysaccounts,cn=etc,dc=infra,dc=sololab"
#     # bindpass     = var.ldap_bindpass
#     # userdn       = "cn=users,cn=accounts,dc=infra,dc=sololab"
#     # userattr     = "mail"
#     # groupfilter  = "(&(objectClass=posixgroup)(cn=svc-vault-*)(member:={{.UserDN}}))"
#     # groupdn      = "cn=groups,cn=accounts,dc=infra,dc=sololab"
#     # groupattr    = "cn"

#     # lldap
#     binddn   = "cn=readonly,ou=people,dc=root,dc=sololab"
#     bindpass = "readonly"
#     userdn   = "ou=people,dc=root,dc=sololab"
#     userattr = "uid"
#     # userfilter = "({{.UserAttr}}={{.Username}})"
#     # do not use upper case group name
#     userfilter = "(&({{.UserAttr}}={{.Username}})(objectClass=person)(memberOf=cn=sso_allow,ou=groups,dc=root,dc=sololab))"
#     groupdn    = "ou=groups,dc=root,dc=sololab"
#     groupattr  = "cn"
#     # groupfilter = "(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
#     groupfilter = "(&(objectClass=groupOfUniqueNames)(cn=app-*)(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})))"
#   }

#   ldap_users_sync = [
#     for entry in data.ldap_entries.users.entries : jsondecode(entry.data_json).uid[0]
#   ]

#   ldap_groups_sync = [
#     for entry in data.ldap_entries.groups.entries : jsondecode(entry.data_json).cn[0]
#   ]

#   # vault policies
#   # vault_policies = {
#   #   vault-root = {
#   #     # policy_content = <<-EOT
#   #     #   path "secret/*" 
#   #     #   {
#   #     #     capabilities = [ "create", "read", "update", "delete", "list", "patch" ]
#   #     #   }
#   #     #   # Manage identity
#   #     #   path "identity/*"
#   #     #   {
#   #     #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
#   #     #   }
#   #     #   path "sys/health"
#   #     #   {
#   #     #     capabilities = ["read", "sudo"]
#   #     #   }
#   #     #   # Create and manage ACL policies broadly across Vault
#   #     #   # List existing policies
#   #     #   path "sys/policies/acl"
#   #     #   {
#   #     #     capabilities = ["list"]
#   #     #   }
#   #     #   # Create and manage ACL policies
#   #     #   path "sys/policies/acl/*"
#   #     #   {
#   #     #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
#   #     #   }
#   #     #   # Enable and manage authentication methods broadly across Vault
#   #     #   # Manage auth methods broadly across Vault
#   #     #   path "auth/*"
#   #     #   {
#   #     #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
#   #     #   }
#   #     #   # Create, update, and delete auth methods
#   #     #   path "sys/auth/*"
#   #     #   {
#   #     #     capabilities = ["create", "update", "delete", "sudo"]
#   #     #   }
#   #     #   # List auth methods
#   #     #   path "sys/auth"
#   #     #   {
#   #     #     capabilities = ["read"]
#   #     #   }
#   #     #   # Enable and manage the key/value secrets engine at `secret/` path
#   #     #   # List, create, update, and delete key/value secrets
#   #     #   path "secret/*"
#   #     #   {
#   #     #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
#   #     #   }
#   #     #   # Manage secrets engines
#   #     #   path "sys/mounts/*"
#   #     #   {
#   #     #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
#   #     #   }
#   #     #   # List existing secrets engines.
#   #     #   path "sys/mounts"
#   #     #   {
#   #     #     capabilities = ["read"]
#   #     #   }
#   #     # EOT
#   #     policy_content = <<-EOT
#   #     path "*" {
#   #         capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
#   #     }
#   #     EOT
#   #   }
#   # }

#   # # groups
#   # vault_groups = {
#   #   vault-root = {
#   #     type     = "external"
#   #     policies = ["vault-root"]
#   #     alias = [
#   #       {
#   #         name     = "app-vault-root"
#   #         ldap_key = "sololab"
#   #       }
#   #     ]
#   #   }
#   #   minio-default = {
#   #     type     = "external"
#   #     policies = ["default"]
#   #     alias = [
#   #       {
#   #         name     = "app-minio-default"
#   #         ldap_key = "sololab"
#   #       }
#   #     ]
#   #   }
#   #   minio-all-ro = {
#   #     type     = "external"
#   #     policies = ["default"]
#   #     alias = [
#   #       {
#   #         name     = "app-minio-all-ro"
#   #         ldap_key = "sololab"
#   #       }
#   #     ]
#   #   }
#   # }
# }
