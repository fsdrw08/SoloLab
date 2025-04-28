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

# resource "powerdns_zone" "zone" {
#   name         = "day0.sololab."
#   kind         = "Native"
#   soa_edit_api = "DEFAULT"
#   nameservers = [
#     "ns1.day0.sololab."
#   ]
# }

# resource "powerdns_record" "SOA" {
#   zone = powerdns_zone.zone.name
#   name = "day0.sololab."
#   type = "SOA"
#   ttl  = 86400
#   records = [
#     "ns1.day0.sololab. day0.sololab. 2025030201 3600 600 1814400 7200"
#   ]
# }

# # name server
# resource "powerdns_record" "ns1" {
#   zone = powerdns_zone.zone.name
#   name = "ns1.day0.sololab."
#   type = "A"
#   ttl  = 86400
#   records = [
#     "192.168.255.1"
#   ]
# }

# resource "powerdns_record" "etcd_SRV" {
#   zone = powerdns_zone.zone.name
#   name = "_etcd-server-ssl._tcp.day0.sololab."
#   type = "SRV"
#   ttl  = 300
#   records = [
#     "0 10 2380 etcd-0.day0.sololab.",
#     # "0 10 2380 etcd-1.day0.sololab.",
#     # "0 10 2380 etcd-2.day0.sololab.",
#   ]
# }

# resource "powerdns_record" "etcd_A" {
#   zone = powerdns_zone.zone.name
#   name = "etcd-0.day0.sololab."
#   type = "A"
#   ttl  = 86400
#   records = [
#     "192.168.255.20"
#   ]
# }
