# # vault
# # download vault zip
# resource "system_file" "vault_zip" {
#   source = var.vault.install.zip_file_source
#   path   = var.vault.install.zip_file_path # "/usr/bin/vault"
# }

# # unzip and put it to /usr/bin/
# resource "null_resource" "vault_bin" {
#   depends_on = [system_file.vault_zip]
#   triggers = {
#     file_source = var.vault.install.zip_file_source
#     file_dir    = var.vault.install.bin_file_dir
#     host        = var.vm_conn.host
#     port        = var.vm_conn.port
#     user        = var.vm_conn.user
#     password    = sensitive(var.vm_conn.password)
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
#       "sudo unzip ${system_file.vault_zip.path} -d ${var.vault.install.bin_file_dir} -o",
#       "sudo chmod 755 ${var.vault.install.bin_file_dir}/vault",
#       # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
#       # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.vault.install.bin_file_dir}/vault"
#     ]
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "sudo rm -f ${self.triggers.file_dir}/vault",
#     ]
#   }
# }

# # prepare vault config dir
# resource "system_folder" "vault_config" {
#   path = var.vault.config.file_path_dir
# }

# # persist vault config file in dir
# resource "system_file" "vault_config" {
#   depends_on = [system_folder.vault_config]
#   path       = format("${var.vault.config.file_path_dir}/%s", basename("${var.vault.config.file_source}"))
#   content    = templatefile(var.vault.config.file_source, var.vault.config.vars)
# }

# resource "system_link" "vault_data" {
#   path   = var.vault.storage.dir_link
#   target = var.vault.storage.dir_target
#   user   = var.vault.runas.user
#   group  = var.vault.runas.group
#   connection {
#     type     = "ssh"
#     host     = var.vm_conn.host
#     port     = var.vm_conn.port
#     user     = var.vm_conn.user
#     password = var.vm_conn.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo mkdir -p ${var.vault.storage.dir_target}",
#       "sudo chown ${var.vault.runas.user}:${var.vault.runas.group} ${var.vault.storage.dir_target}",
#     ]
#   }
# }
