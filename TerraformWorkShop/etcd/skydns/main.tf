resource "etcd_key" "keys" {
  for_each = {
    for kv in var.kv_pairs : kv.key => kv
  }
  key   = each.value.key
  value = jsonencode(each.value.value)
}
