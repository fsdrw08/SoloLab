resource "etcd_key" "dns_records" {
  for_each = {
    for dns_record in var.dns_records : dns_record.hostname => dns_record
  }
  key = join("/", flatten([each.value.path, reverse(split(".", each.value.hostname)), ""]))
  value = jsonencode(
    merge(each.value.value.string_map, each.value.value.number_map)
  )
}
