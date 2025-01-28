module "policy_bindings" {
  source          = "../../modules/vault-policy_binding"
  policy_bindings = var.policy_bindings

}
