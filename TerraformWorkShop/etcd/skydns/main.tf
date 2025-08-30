resource "etcd_key" "keys" {
  for_each = {
    for kv in var.kv_pairs : kv.hostname => kv
  }
  key = join("/", flatten([each.value.path, reverse(split(".", each.value.hostname)), ""]))
  value = jsonencode(
    merge(each.value.value.string_map, each.value.value.number_map)
  )
}
