resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<-EOT
  path "*" {
    capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
  }
  EOT
}

resource "vault_identity_group" "admin" {
  name                       = "admin"
  type                       = "internal"
  external_policies          = true
  external_member_group_ids  = true
  external_member_entity_ids = true
}

resource "vault_identity_group_policies" "admin" {
  policies = [
    vault_policy.admin.name
  ]

  exclusive = true

  group_id = vault_identity_group.admin.id
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

data "vault_identity_entity" "admin" {
  entity_name = "admin"
}

resource "vault_identity_group_member_entity_ids" "admin" {
  depends_on = [data.vault_identity_entity.admin]
  group_id   = vault_identity_group.admin.id
  member_entity_ids = [
    data.vault_identity_entity.admin.entity_id
  ]
}
