resource "powerdns_zone" "zones" {
  for_each = {
    for zone in var.zones : zone.name => zone
  }
  name         = each.key
  kind         = "Native"
  soa_edit_api = "DEFAULT"
  nameservers  = each.value.nameservers
}

locals {
  records = flatten([
    for zone in var.zones : [
      for record in zone.records : {
        zone    = zone.name
        fqdn    = record.fqdn
        type    = record.type
        ttl     = record.ttl
        results = record.results
      }
    ]
  ])
}

resource "powerdns_record" "records" {
  for_each = {
    for record in local.records : record.fqdn => record
  }
  zone    = powerdns_zone.zones[each.value.zone].name
  name    = each.value.fqdn
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.results
}

# resource "null_resource" "post_process" {
#   depends_on = [
#     powerdns_zone.zones,
#   ]
#   for_each = var.post_process == null ? {} : var.post_process
#   triggers = {
#     script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
#     host           = var.prov_remote.host
#     port           = var.prov_remote.port
#     user           = var.prov_remote.user
#     password       = sensitive(var.prov_remote.password)
#   }
#   connection {
#     type     = "ssh"
#     host     = self.triggers.host
#     port     = self.triggers.port
#     user     = self.triggers.user
#     password = self.triggers.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       templatefile("${each.value.script_path}", "${each.value.vars}")
#     ]
#   }
# }
