data "vault_kv_secret_v2" "ca_cert" {
  mount = "kvv2-certs"
  name  = "root"
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
  mount = "kvv2-consul"
  name  = "key-gossip_encryption"
  data_json = jsonencode(
    {
      key = "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w="
    }
  )
}
