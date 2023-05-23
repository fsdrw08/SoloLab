variable "cloud_init" {
  type = object({
    path    = string
    content = map(string)
  })

  description = "cloud init nocloud related file name and file content in this var, perform as key-value"

  default = {
    path = "./cloud-init.iso"
    content = {
      # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#configuration-methods
      # https://developer.hashicorp.com/terraform/language/expressions/strings#indented-heredocs
      user-data      = <<-EOT
      #cloud-config
      timezone: Asia/Shanghai
      EOT
      network-config = <<-EOT
      version: 2
      ethernets:
        eth0:
          dhcp4: true
      EOT
    }
  }
}

# variable "cloud_init" {
#   type        = map(string)
#   description = "cloud init nocloud related file name and file content in this var, perform as key-value"
#   default = {
#     # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#configuration-methods
#     # https://developer.hashicorp.com/terraform/language/expressions/strings#indented-heredocs
#     user-data      = <<-EOT
#     #cloud-config
#     timezone: Asia/Shanghai
#     EOT
#     network-config = <<-EOT
#     version: 2
#     ethernets:
#       eth0:
#         dhcp4: true
#     EOT
#   }
# }

# variable "iso_file" {
#   type    = string
#   default = "./cloud-init.iso"
# }

variable "windows_create_iso" {
  type        = string
  description = "command in windows powershell to create iso file"
  default     = ""
  # default     = "oscdimg.exe ${path.root}/.terraform/tmp/cloud-init ${path.module}/cloud-init.iso -j2 -lcidata"
  # default = "oscdimg.exe ./.terraform/tmp/cloud-init ./cloud-init.iso -j2 -lcidata"
}

variable "bash_create_iso" {
  type        = string
  description = "command in bash to create iso file"
  default     = ""
  # default     = "genisoimage -output ./cloud-init.iso -volid cidata -joliet -rock ./.terraform/tmp/cloud-init/*"
}

variable "windows_remove_iso" {
  type        = string
  description = "command in windows powershell to remove the iso file when destroy"
  default     = ""
  # default     = <<-EOT
  # if (Test-Path ./cloud-init.iso) {
  #   Remove-Item ./cloud-init.iso
  # }
  # EOT
}

variable "bash_remove_iso" {
  type        = string
  description = "command in bash to remove the iso file when destroy"
  default     = ""
  # https://stackoverflow.com/questions/40082346/how-to-check-if-a-file-exists-in-a-shell-script
  # https://linuxize.com/post/bash-check-if-file-exists/
  # default = "[ -f ./cloud-init.iso ] && rm -f ./cloud-init.iso"
}

variable "windows_remove_tmp_dir" {
  type        = string
  description = "command in windows powershell to remove the iso file when destroy"
  default     = <<-EOT
  if (Test-Path ./.terraform/tmp/cloud-init) {
    Remove-Item ./.terraform/tmp/cloud-init -Recurse
  }
  EOT
}

variable "bash_remove_tmp_dir" {
  type        = string
  description = "command in bash to remove the iso file when destroy"
  default     = <<-EOT
  [ -d ./.terraform/tmp/cloud-init ] && rm -rf ./.terraform/tmp/cloud-init
  EOT
}
