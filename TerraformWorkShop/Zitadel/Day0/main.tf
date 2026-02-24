data "terraform_remote_state" "tfstate" {
  backend = "local"
  config = {
    path = "../../../TLS/RootCA/terraform.tfstate"
  }
}

resource "zitadel_idp_ldap" "idp_ldap" {
  name      = var.ldap.name
  servers   = var.ldap.servers
  start_tls = var.ldap.start_tls
  timeout   = var.ldap.timeout

  base_dn          = var.ldap.base_dn
  bind_dn          = var.ldap.bind_dn
  bind_password    = var.ldap.bind_password
  is_auto_creation = var.ldap.is_auto_creation
  # If this setting is enabled, the user will be updated within ZITADEL, if some user data is changed withing the provider.
  # E.g if the lastname changes on the LDAP user, the information will be changed on the ZITADEL account on the next login.
  is_auto_update      = var.ldap.is_auto_update
  is_creation_allowed = var.ldap.is_creation_allowed
  is_linking_allowed  = var.ldap.is_linking_allowed
  user_base           = var.ldap.user_base
  user_object_classes = var.ldap.user_object_classes
  user_filters        = var.ldap.user_filters
  root_ca             = data.terraform_remote_state.tfstate.outputs.root_cert_pem
}

resource "zitadel_org" "org" {
  name = "sololab"
}

resource "zitadel_default_login_policy" "login_policy" {
  user_login                    = true
  allow_register                = true
  allow_external_idp            = true
  force_mfa                     = false
  force_mfa_local_only          = false
  passwordless_type             = "PASSWORDLESS_TYPE_ALLOWED"
  hide_password_reset           = "false"
  password_check_lifetime       = "240h0m0s"
  external_login_check_lifetime = "240h0m0s"
  multi_factor_check_lifetime   = "24h0m0s"
  mfa_init_skip_lifetime        = "720h0m0s"
  second_factor_check_lifetime  = "24h0m0s"
  ignore_unknown_usernames      = true
  default_redirect_uri          = "${var.prov_zitadel.domain}:443"
  idps                          = [zitadel_idp_ldap.idp_ldap.id]
  allow_domain_discovery        = true
}

# resource "zitadel_application_oidc" "default" {
#   project_id = data.zitadel_project.default.id
#   org_id     = data.zitadel_org.default.id

#   name                         = "applicationoidc"
#   redirect_uris                = ["https://localhost.com"]
#   response_types               = ["OIDC_RESPONSE_TYPE_CODE"]
#   grant_types                  = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
#   post_logout_redirect_uris    = ["https://localhost.com"]
#   app_type                     = "OIDC_APP_TYPE_WEB"
#   auth_method_type             = "OIDC_AUTH_METHOD_TYPE_BASIC"
#   version                      = "OIDC_VERSION_1_0"
#   clock_skew                   = "0s"
#   dev_mode                     = true
#   access_token_type            = "OIDC_TOKEN_TYPE_BEARER"
#   access_token_role_assertion  = false
#   id_token_role_assertion      = false
#   id_token_userinfo_assertion  = false
#   additional_origins           = []
#   skip_native_app_success_page = false
# }
