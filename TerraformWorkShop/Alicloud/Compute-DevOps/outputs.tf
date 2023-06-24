output "root_private_key" {
  value     = tls_private_key.root.private_key_pem
  sensitive = true
}

output "admin_private_key" {
  value     = tls_private_key.admin.private_key_pem
  sensitive = true
}

output "podmgr_private_key" {
  value     = tls_private_key.podmgr.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = data.alicloud_eip_addresses.eip.addresses[var.eip_index].ip_address
}
