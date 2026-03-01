# Retrieve Cert via Nexus
data "nexus_security_ssl" "ssl" {
  host = var.ldap.host
  port = var.ldap.port
}

# Import Cert into Nexus
resource "nexus_security_ssl_truststore" "ssl_truststore" {
  pem = data.nexus_security_ssl.ssl.pem
}

resource "nexus_security_ldap" "ldap" {
  auth_password                  = var.ldap.auth_password
  auth_realm                     = var.ldap.auth_realm
  auth_schema                    = var.ldap.auth_schema
  auth_username                  = var.ldap.auth_username
  connection_retry_delay_seconds = var.ldap.connection_retry_delay_seconds
  connection_timeout_seconds     = var.ldap.connection_timeout_seconds
  group_base_dn                  = var.ldap.group_base_dn
  group_id_attribute             = var.ldap.group_id_attribute
  group_member_attribute         = var.ldap.group_member_attribute
  group_member_format            = var.ldap.group_member_format
  group_object_class             = var.ldap.group_object_class
  group_subtree                  = var.ldap.group_subtree
  group_type                     = var.ldap.group_type
  host                           = var.ldap.host
  ldap_groups_as_roles           = var.ldap.ldap_groups_as_roles
  max_incident_count             = var.ldap.max_incident_count
  name                           = var.ldap.name
  port                           = var.ldap.port
  protocol                       = var.ldap.protocol
  search_base                    = var.ldap.search_base
  use_trust_store                = var.ldap.use_trust_store
  user_base_dn                   = var.ldap.user_base_dn
  user_email_address_attribute   = var.ldap.user_email_address_attribute
  user_id_attribute              = var.ldap.user_id_attribute
  user_ldap_filter               = var.ldap.user_ldap_filter
  user_member_of_attribute       = var.ldap.user_member_of_attribute
  user_object_class              = var.ldap.user_object_class
  user_password_attribute        = var.ldap.user_password_attribute
  user_real_name_attribute       = var.ldap.user_real_name_attribute
  user_subtree                   = var.ldap.user_subtree
}

resource "nexus_security_role" "role" {
  for_each = {
    for role in var.roles : role.roleid => role
  }
  roleid      = each.value.roleid
  name        = each.value.name
  description = "Role for ${each.value.name}"
  privileges  = each.value.privileges
}
