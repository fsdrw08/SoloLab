# ldap auth
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/ldap_auth_backend
resource "vault_ldap_auth_backend" "ldap" {
  for_each = 

  path = var.ldap_path
  # ldap connection
  url          = var.ldap_url
  starttls     = var.ldap_starttls
  insecure_tls = var.ldap_insecure_tls
  certificate  = var.ldap_certificate
  # Binding - Authenticated Search
  binddn   = var.ldap_binddn
  bindpass = var.ldap_bindpass
  # User resolution
  userdn   = var.ldap_userdn
  userattr = var.ldap_userattr
  # Group Membership Resolution
  groupdn     = var.ldap_groupdn
  groupattr   = var.ldap_groupattr
  groupfilter = var.ldap_groupfilter
}
