prov_zitadel = {
  domain           = "zitadel.day0.sololab"
  insecure         = false
  port             = 443
  jwt_profile_file = "../zitadel-admin-sa.json"
}

prov_etcd = {
  endpoints = "https://etcd-0.day0.sololab:443"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

# https://github.com/zitadel/terraform-provider-zitadel/issues/30
ldap = {
  name      = "ldap"
  servers   = ["ldap://lldap.day0.sololab"]
  start_tls = false
  timeout   = "10s"

  base_dn             = "dc=root,dc=sololab"
  bind_dn             = "cn=readonly,ou=people,dc=root,dc=sololab"
  bind_password       = "readonly"
  user_base           = "ou=people,dc=root,dc=sololab"
  user_object_classes = ["posixAccount"]
  #   https://github.com/zitadel/zitadel/discussions/10820
  #   https://zitadel.com/docs/guides/integrate/identity-providers/ldap
  user_filters        = ["uid", "objectClass=person", "memberOf=cn=sso_allow,ou=groups,dc=root,dc=sololab"]
  is_linking_allowed  = false
  is_creation_allowed = true
  is_auto_creation    = true
  is_auto_update      = true
}
