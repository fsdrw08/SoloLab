output "root_private_key" {
  value     = tls_private_key.root.private_key_pem
  sensitive = true
}

output "admin_private_key" {
  value     = tls_private_key.admin.private_key_pem
  sensitive = true
}


# # https://developer.hashicorp.com/terraform/cli/commands/console#scripting
# # https://stackoverflow.com/questions/68761944/using-element-and-split-gets-first-item-rather-than-last-item-in-terraform
# output "message_public" {
#   value = <<-EOT
#   run below command in powershell to connect to the server from public
#   ```powershell
#   $user = "admin"
#   $keyName = "${reverse(split("/", "${local_sensitive_file.admin.filename}"))[0]}"
#   $keyPath = Join-Path -Path $(echo 'abspath(path.root)' | terraform console).replace('"','') -ChildPath $keyName
#   $port = "8022"
#   ssh -o "StrictHostKeyChecking=no" -i $keyPath $user@$(terraform output --raw public_ip) -p $port
#   ```

#   or run blow powershell command to generate the ssh config block, paste it into $HOME/.ssh/config
#   ```powershell
#   $publicIP = $(terraform output --raw public_ip)
#   $keyName = "${reverse(split("/", "${local_sensitive_file.admin.filename}"))[0]}"
#   $identifyFile = Join-Path -Path $(echo 'abspath(path.root)' | terraform console).replace('"','') -ChildPath $keyName
#   @"
#   Host git_public
#       HostName $publicIP
#       User admin
#       Port 8022
#       UserKnownHostsFile /dev/null
#       StrictHostKeyChecking no
#       PasswordAuthentication no
#       IdentityFile $identifyFile
#       IdentitiesOnly yes
#       LogLevel FATAL
#   "@
#   code $HOME\.ssh\config
#   # add admin key to ansible
#   terraform output -raw admin_private_key | Out-File -FilePath (Join-Path -Path $(git rev-parse --show-toplevel) -ChildPath AnsibleWorkShop/runner/env/admin.key) -Encoding UTF8NoBOM -Force
#   # add podmgr key to ansible
#   terraform output -raw podmgr_private_key | Out-File -FilePath (Join-Path -Path $(git rev-parse --show-toplevel) -ChildPath AnsibleWorkShop/runner/env/podmgr.key) -Encoding UTF8NoBOM -Force
#   # set podmgr password and login
#   ssh git_public
#   sudo passwd podmgr
#   sudo su podmgr
#   ```
#   EOT
# }

# output "private_ip" {
#   value = alicloud_instance.ecs.private_ip
# }

# output "message_private" {
#   value = <<-EOT
#   run below command in powershell to connect to the server from vpn
#   ```powershell
#   $user = "admin"
#   $keyName = "${reverse(split("/", "${local_sensitive_file.admin.filename}"))[0]}"
#   $keyPath = Join-Path -Path $(echo 'abspath(path.root)' | terraform console).replace('"','') -ChildPath $keyName
#   $port = "22"
#   ssh -o "StrictHostKeyChecking=no" -i $keyPath $user@$(terraform output --raw private_ip) -p $port
#   ```

#   or run blow powershell command to generate the ssh config block, paste it into $HOME/.ssh/config
#   ```powershell
#   $privateIP = $(terraform output --raw private_ip)
#   $keyName = "${reverse(split("/", "${local_sensitive_file.admin.filename}"))[0]}"
#   $identifyFile = Join-Path -Path $(echo 'abspath(path.root)' | terraform console).replace('"','') -ChildPath $keyName
#   @"
#   Host git_private
#       HostName $privateIP
#       User admin
#       Port 22
#       UserKnownHostsFile /dev/null
#       StrictHostKeyChecking no
#       PasswordAuthentication no
#       IdentityFile $identifyFile
#       IdentitiesOnly yes
#       LogLevel FATAL
#   "@
#   code $HOME\.ssh\config
#   # add admin key to ansible
#   terraform output -raw admin_private_key | Out-File -FilePath (Join-Path -Path $(git rev-parse --show-toplevel) -ChildPath AnsibleWorkShop/runner/env/admin.key) -Encoding UTF8NoBOM -Force
#   # add podmgr key to ansible
#   terraform output -raw podmgr_private_key | Out-File -FilePath (Join-Path -Path $(git rev-parse --show-toplevel) -ChildPath AnsibleWorkShop/runner/env/podmgr.key) -Encoding UTF8NoBOM -Force
#   # set podmgr password and login
#   ssh git_private
#   sudo passwd podmgr
#   sudo su podmgr
#   ```
#   EOT
# }
