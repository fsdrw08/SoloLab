resource "vyos_config_block_tree" "reverse_proxy" {
  for_each = var.reverse_proxy
  path     = each.value.path
  configs  = each.value.configs
}
