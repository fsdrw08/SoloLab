variable "cloudinit_config" {
  type = object({
    isoPath = string
    part = list(object({
      filename = string
      content  = string
    }))
  })

  description = "cloud init nocloud related file name and file content in this var, perform as key-value"

  default = {
    isoPath = "./cloud-init.iso"
    part = [
      {
        # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#configuration-methods
        # https://developer.hashicorp.com/terraform/language/expressions/strings#indented-heredocs
        filename = "user-data"
        content  = <<-EOT
          #cloud-config
          timezone: Asia/Shanghai
          EOT
      },
      {
        filename = "network-config"
        content  = <<-EOT
          version: 2
          ethernets:
            eth0:
              dhcp4: true
          EOT
      }
    ]
  }
}

variable "windows_create_iso" {
  type        = string
  description = "command in windows powershell to create iso file"
  default     = "oscdimg.exe ./.terraform/tmp/$tempDir $isoPath -j2 -lcidata"
}

variable "bash_create_iso" {
  type        = string
  description = "command in bash to create iso file"
  default     = "genisoimage -output $isoPath -volid cidata -joliet -rock ./.terraform/tmp/$tempDir/*"
}

variable "windows_remove_iso" {
  type        = string
  description = "command in windows powershell to remove the iso file when destroy"
  default     = <<-EOT
  if (Test-Path $isoPath) {
    Remove-Item $isoPath
  }
  EOT
}

variable "bash_remove_iso" {
  type        = string
  description = "command in bash to remove the iso file when destroy"
  # https://stackoverflow.com/questions/40082346/how-to-check-if-a-file-exists-in-a-shell-script
  # https://linuxize.com/post/bash-check-if-file-exists/
  default = "[ -f $isoPath ] && rm -f $isoPath"
}

variable "windows_remove_tmp_dir" {
  type        = string
  description = "command in windows powershell to remove the iso file when destroy"
  default     = <<-EOT
  if (Test-Path ./.terraform/tmp/$tempDir) {
    Remove-Item ./.terraform/tmp/$tempDir -Recurse
  }
  EOT
}

variable "bash_remove_tmp_dir" {
  type        = string
  description = "command in bash to remove the iso file when destroy"
  default     = <<-EOT
  [ -d ./.terraform/tmp/$tempDir ] && rm -rf ./.terraform/tmp/$tempDir
  EOT
}
