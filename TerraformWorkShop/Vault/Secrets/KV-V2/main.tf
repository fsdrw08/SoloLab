resource "vault_mount" "mount" {
  for_each = {
    for kvv2 in var.kvv2 : kvv2.mount_path => kvv2
  }
  path        = each.value.mount_path
  type        = "kv"
  options     = { version = "2" }
  description = each.value.description
}

resource "vault_kv_secret_backend_v2" "kvv2" {
  for_each = {
    for kvv2 in var.kvv2 : kvv2.mount_path => kvv2
    if kvv2.config != null
  }
  mount                = vault_mount.mount[each.key].path
  max_versions         = each.value.max_versions
  delete_version_after = each.value.delete_version_after
}
