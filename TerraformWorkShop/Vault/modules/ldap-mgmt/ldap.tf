# ldap auth
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/ldap_auth_backend
resource "vault_ldap_auth_backend" "ldap" {
  for_each = var.vault_ldap_auth

  url                  = each.value.url
  starttls             = each.value.starttls
  case_sensitive_names = each.value.case_sensitive_names
  tls_min_version      = each.value.tls_min_version
  tls_max_version      = each.value.tls_max_version
  insecure_tls         = each.value.insecure_tls
  certificate          = each.value.certificate
  binddn               = each.value.binddn
  bindpass             = each.value.bindpass
  userdn               = each.value.userdn
  userattr             = each.value.userattr
  userfilter           = each.value.userfilter
  upndomain            = each.value.upndomain
  discoverdn           = each.value.discoverdn
  deny_null_bind       = each.value.deny_null_bind
  groupfilter          = each.value.groupfilter
  groupdn              = each.value.groupdn
  groupattr            = each.value.groupattr
  username_as_alias    = each.value.username_as_alias
  use_token_groups     = each.value.use_token_groups
  path                 = each.value.path
  disable_remount      = each.value.disable_remount
  description          = each.value.description
  local                = each.value.local

  # Common Token Arguments
  token_ttl               = each.value.token_ttl
  token_max_ttl           = each.value.token_max_ttl
  token_period            = each.value.token_period
  token_policies          = each.value.token_policies
  token_bound_cidrs       = each.value.token_bound_cidrs
  token_explicit_max_ttl  = each.value.token_explicit_max_ttl
  token_no_default_policy = each.value.token_no_default_policy
  token_num_uses          = each.value.token_num_uses
  token_type              = each.value.token_type

  # # ldap connection
  # url          = var.ldap_url
  # starttls     = var.ldap_starttls
  # insecure_tls = var.ldap_insecure_tls
  # certificate  = var.ldap_certificate
  # # Binding - Authenticated Search
  # binddn   = var.ldap_binddn
  # bindpass = var.ldap_bindpass
  # # User resolution
  # userdn   = var.ldap_userdn
  # userattr = var.ldap_userattr
  # # Group Membership Resolution
  # groupdn     = var.ldap_groupdn
  # groupattr   = var.ldap_groupattr
  # groupfilter = var.ldap_groupfilter
  # path = var.ldap_path
}
