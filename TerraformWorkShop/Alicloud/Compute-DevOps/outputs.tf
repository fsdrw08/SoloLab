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

output "message" {
  value = <<-EOT
  run below command in powershell to connect to the server
  $keyPath="$home\.ssh\gitlab.pem"
  $user="admin"
  $port="8022"
  terraform output --raw "$($user)_private_key" | out-file -Path $keyPath -Encoding utf8 -Force
  ssh -o "StrictHostKeyChecking=no" -i $keyPath $user@$(terraform output --raw public_ip) -p $port
  EOT
}
