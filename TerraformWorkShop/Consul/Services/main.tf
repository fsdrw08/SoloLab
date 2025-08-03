resource "consul_node" "nodes" {
  for_each = {
    for node in var.nodes : node.name => node
  }
  name    = each.value.name
  address = each.value.address
}

resource "consul_service" "services" {
  depends_on = [consul_node.nodes]
  for_each = {
    for service in var.services : service.name => service
  }
  name = each.value.name
  node = each.value.node

  datacenter          = each.value.datacenter
  meta                = each.value.meta
  namespace           = each.value.namespace
  address             = each.value.address
  port                = each.value.port
  service_id          = each.value.service_id
  enable_tag_override = each.value.enable_tag_override

  dynamic "check" {
    iterator = check
    for_each = each.value.check

    content {
      name     = lookup(check.value, "name", null)
      interval = lookup(check.value, "interval", null)
      timeout  = lookup(check.value, "timeout", null)

      check_id                          = lookup(check.value, "check_id", null)
      notes                             = lookup(check.value, "notes", null)
      status                            = lookup(check.value, "status", null)
      tcp                               = lookup(check.value, "tcp", null)
      http                              = lookup(check.value, "http", null)
      tls_skip_verify                   = lookup(check.value, "tls_skip_verify", null)
      method                            = lookup(check.value, "method", null)
      deregister_critical_service_after = lookup(check.value, "deregister_critical_service_after", null)

      dynamic "header" {
        iterator = header
        for_each = lookup(check.value, "header", [])

        content {
          name  = lookup(header.value, "name", null)
          value = lookup(header.value, "value", null)
        }
      }
    }
  }
  tags = each.value.tags
}
