resource "vault_policy" "policies" {
  for_each = var.vault_policies

  name   = each.key
  policy = each.value.policy_content
}
