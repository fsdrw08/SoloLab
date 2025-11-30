resource "vyos_config_block_tree" "service_monitoring" {
  for_each = var.service_monitoring
  path     = each.value.path
  configs  = each.value.configs
}

resource "vyos_config_block_tree" "reverse_proxy" {
  for_each = var.reverse_proxy
  path     = each.value.path
  configs  = each.value.configs
}

resource "system_file" "consul_service" {
  for_each = toset([
    "./attachments/exporter.consul.hcl",
  ])
  path    = "/mnt/data/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
