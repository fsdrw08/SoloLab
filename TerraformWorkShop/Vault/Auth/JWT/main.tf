# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "vault_kv_secret_v2" "secret" {
  count = var.jwt_auth.jwks_ca_pem.vault_kvv2 != null ? 1 : 0
  mount = var.jwt_auth.jwks_ca_pem.vault_kvv2.mount
  name  = var.jwt_auth.jwks_ca_pem.vault_kvv2.name
}

resource "vault_jwt_auth_backend" "backend" {
  path               = var.jwt_auth.path
  description        = var.jwt_auth.description
  jwks_ca_pem        = var.jwt_auth.jwks_ca_pem.plaintext != null ? var.jwt_auth.jwks_ca_pem.plaintext : data.vault_kv_secret_v2.secret[0].data[var.jwt_auth.jwks_ca_pem.vault_kvv2.key]
  jwks_url           = var.jwt_auth.jwks_url
  jwt_supported_algs = var.jwt_auth.jwt_supported_algs
  default_role       = var.jwt_auth.default_role
}

resource "vault_jwt_auth_backend_role" "backend_role" {
  for_each = {
    for role in var.jwt_auth.roles : role.role_name => role
  }
  backend                 = vault_jwt_auth_backend.backend.path
  role_name               = each.value.role_name
  role_type               = each.value.role_type
  bound_audiences         = each.value.bound_audiences
  user_claim              = each.value.user_claim
  user_claim_json_pointer = each.value.user_claim_json_pointer
  claim_mappings          = each.value.claim_mappings
  token_type              = each.value.token_type
  token_policies          = each.value.token_policies
  # https://developer.hashicorp.com/vault/docs/concepts/tokens#periodic-tokens
  token_period           = each.value.token_period
  token_explicit_max_ttl = each.value.token_explicit_max_ttl
}

# vault_policy.nomad_workload is a sample ACL policy that grants tasks read
# access to secrets in the path "kvv2_nomad/<job namespace>/<job ID>/*" to
# illustrate how policies can reference values from the claim_mappings defined
# in vault_jwt_auth_backend_role.nomad_workload.
#
# Refer to the Vault documentation for more information on templated ACL
# policies.
# https://developer.hashicorp.com/vault/tutorials/policies/policy-templating#create-templated-acl-policies
#
# This is the policy used in vault_jwt_auth_backend_role.nomad_workload if the
# variable policy_names is not set.

# resource "vault_policy" "nomad_workload" {
#   name   = var.default_policy_name
#   policy = <<EOT
# path "kvv2_nomad/data/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}/*" {
#   capabilities = ["read"]
# }

# path "kvv2_nomad/data/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}" {
#   capabilities = ["read"]
# }

# path "kvv2_nomad/metadata/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_namespace}}/*" {
#   capabilities = ["list"]
# }

# path "kvv2_nomad/metadata/*" {
#   capabilities = ["list"]
# }
# EOT
# }
