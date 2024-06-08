resource "vault_policy" "consul_auto_config" {
  name   = "consul-auto_config"
  policy = <<-EOT
  path "identity/oidc/token/consul_auto_config" {
    capabilities = ["read"]
  }
  path "identity/entity/id" {
    capabilities = ["list"]
  }
  path "identity/entity/id/{{identity.entity.id}}" {
    capabilities = ["read", "update"]
  }
  EOT
}

# resource "vault_identity_group" "consul_auto_config" {
#   name                       = "consul_auto_config"
#   type                       = "internal"
#   external_policies          = true
#   external_member_group_ids  = true
#   external_member_entity_ids = true
# }

data "vault_identity_group" "consul_auto_config" {
  group_name = "App-Consul-Auto_Config"
}

resource "vault_identity_group_policies" "consul_auto_config" {
  policies = [
    vault_policy.consul_auto_config.name
  ]

  exclusive = true

  group_id = data.vault_identity_group.consul_auto_config.id
}

# data "vault_identity_group" "external" {
#   group_name = "app-vault-admin"
# }

# resource "vault_identity_group_member_group_ids" "admin" {
#   group_id = vault_identity_group.admin.id
#   member_group_ids = [
#     # data.vault_identity_group.external.group_id
#   ]
# }

# data "vault_identity_entity" "consul_auto_config" {
#   entity_name = "user1@mail.sololab"
# }

# resource "vault_identity_group_member_entity_ids" "consul_auto_config" {
#   depends_on = [data.vault_identity_entity.consul_auto_config]
#   group_id   = vault_identity_group.consul_auto_config.id
#   member_entity_ids = [
#     data.vault_identity_entity.consul_auto_config.entity_id
#   ]
# }
