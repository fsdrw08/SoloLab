resource "vyos_config_block_tree" "service" {
  for_each = var.services
  path     = each.value.path
  configs  = each.value.configs
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [vyos_config_block_tree.service]
  for_each   = var.reverse_proxy
  path       = each.value.path
  configs    = each.value.configs
}
