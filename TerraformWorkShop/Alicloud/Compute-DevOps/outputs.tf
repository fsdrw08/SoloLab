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

# https://developer.hashicorp.com/terraform/cli/commands/console#scripting
# https://stackoverflow.com/questions/68761944/using-element-and-split-gets-first-item-rather-than-last-item-in-terraform
output "message" {
  value = <<-EOT
  run below command in powershell to connect to the server
  ```powershell
  $user = "admin"
  $keyName = "${reverse(split("/", "${local_sensitive_file.admin.filename}"))[0]}"
  $keyPath = Join-Path -Path $(echo 'abspath(path.root)' | terraform console).replace('"','') -ChildPath $keyName
  $port = "8022"
  ssh -o "StrictHostKeyChecking=no" -i $keyPath $user@$(terraform output --raw public_ip) -p $port
  ```

  or run blow powershell command to generate the ssh config block, paste it into $HOME/.ssh/config
  ```powershell
  $ip = $(terraform output --raw public_ip)
  $keyName = "${reverse(split("/", "${local_sensitive_file.admin.filename}"))[0]}"
  $identifyFile = Join-Path -Path $(echo 'abspath(path.root)' | terraform console).replace('"','') -ChildPath $keyName
  @"
  Host gitlab
      HostName $ip
      User admin
      Port 8022
      UserKnownHostsFile /dev/null
      StrictHostKeyChecking no
      PasswordAuthentication no
      IdentityFile $identifyFile
      IdentitiesOnly yes
      LogLevel FATAL
  "@
  code $HOME\.ssh\config
  ```
  EOT
}
