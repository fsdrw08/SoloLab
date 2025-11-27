data "vault_kv_secret_v2" "ca_cert" {
  mount = "kvv2_certs"
  name  = "sololab_root"
}

resource "vault_consul_secret_backend" "backend" {
  path        = "consul"
  description = "Manages the Consul backend"
  scheme      = var.prov_consul.scheme
  address     = var.prov_consul.address
  token       = var.prov_consul.token
  ca_cert     = data.vault_kv_secret_v2.ca_cert.data["ca"]
}

resource "vault_consul_secret_backend_role" "roles" {
  for_each = {
    for role in var.consul_roles : role.name => role
  }
  name            = each.value.name
  backend         = vault_consul_secret_backend.backend.path
  consul_policies = each.value.consul_policies
  ttl             = each.value.ttl
}

module "consul_jwt_auth_policy_bindings" {
  source = "../../../modules/vault-policy_binding"
  policy_bindings = [
    for role in var.consul_roles : {
      policy_name    = "consul-acl_token-${role.name}"
      policy_content = <<-EOT
      path "consul/creds/${role.name}" {
        capabilities = ["read"]
      }
      EOT
      group_binding = {
        policy_group    = "Policy-Consul-Creds_${role.name}"
        external_groups = role.groups_binding
      }
    }
  ]
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    "key-gossip_encryption" = {
      data = {
        key = "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w="
      }
    }
    "token-init_management" = {
      data = {
        token = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
      }
    }
  }
  mount = "kvv2_consul"
  name  = each.key
  data_json = jsonencode(
    each.value.data
  )
}
