# # Retrieve Cert via Nexus
data "vault_kv_secret_v2" "secret" {
  mount = "kvv2_certs"
  name  = "sololab_root"
}

# # Import Cert into Nexus
resource "sonatyperepo_security_ssl_truststore" "ssl_truststore" {
  pem = data.vault_kv_secret_v2.secret.data.ca
}

resource "sonatyperepo_system_config_ldap_connection" "ldap" {
  auth_scheme               = var.ldap.auth_scheme
  hostname                  = var.ldap.hostname
  name                      = var.ldap.name
  port                      = var.ldap.port
  protocol                  = var.ldap.protocol
  search_base               = var.ldap.search_base
  user_email_name_attribute = var.ldap.user_email_name_attribute
  user_id_attribute         = var.ldap.user_id_attribute
  user_object_class         = var.ldap.user_object_class
  user_real_name_attribute  = var.ldap.user_real_name_attribute

  auth_password             = var.ldap.auth_password
  auth_realm                = var.ldap.auth_realm
  auth_username             = var.ldap.auth_username
  connection_retry_delay    = var.ldap.connection_retry_delay
  connection_timeout        = var.ldap.connection_timeout
  group_base_dn             = var.ldap.group_base_dn
  group_id_attribute        = var.ldap.group_id_attribute
  group_member_attribute    = var.ldap.group_member_attribute
  group_member_format       = var.ldap.group_member_format
  group_object_class        = var.ldap.group_object_class
  group_subtree             = var.ldap.group_subtree
  group_type                = var.ldap.group_type
  map_ldap_groups_to_roles  = var.ldap.map_ldap_groups_to_roles
  max_connection_attempts   = var.ldap.max_connection_attempts
  nexus_trust_store_enabled = var.ldap.nexus_trust_store_enabled
  order                     = var.ldap.order
  user_base_dn              = var.ldap.user_base_dn
  user_ldap_filter          = var.ldap.user_ldap_filter
  user_member_of_attribute  = var.ldap.user_member_of_attribute
  user_password_attribute   = var.ldap.user_password_attribute
  user_subtree              = var.ldap.user_subtree
}

resource "sonatyperepo_role" "role" {
  for_each = {
    for role in var.roles : role.id => role
  }
  description = "Role for ${each.value.name}"
  id          = each.value.id
  name        = each.value.name
  privileges  = each.value.privileges
}

resource "sonatyperepo_user" "user" {
  depends_on = [
    sonatyperepo_role.role
  ]
  for_each = {
    for user in var.local_users : user.user_id => user
  }
  email_address = each.value.email_address
  first_name    = each.value.first_name
  last_name     = each.value.last_name
  roles         = each.value.roles
  status        = each.value.status
  user_id       = each.value.user_id

  password = each.value.password
}