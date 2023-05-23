locals {
  # https://stackoverflow.com/questions/52628749/set-terraform-default-interpreter-for-local-exec
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true

  windows_create_iso = var.windows_create_iso != "" ? var.windows_create_iso : <<-EOT
    oscdimg.exe ./.terraform/tmp/cloud-init ${var.cloud_init.path} -j2 -lcidata
  EOT

  bash_create_iso = var.bash_create_iso != "" ? var.bash_create_iso : <<-EOT
    genisoimage -output ${var.cloud_init.path} -volid cidata -joliet -rock ./.terraform/tmp/cloud-init/*
  EOT

  windows_remove_iso = var.windows_remove_iso != "" ? var.windows_remove_iso : <<-EOT
    if (Test-Path ${var.cloud_init.path}) {
      Remove-Item ${var.cloud_init.path}
    }
  EOT

  bash_remove_iso = var.bash_remove_iso != "" ? var.bash_remove_iso : <<-EOT
    [ -f ${var.cloud_init.path} ] && rm -f ${var.cloud_init.path}
  EOT

  # windows_remove_tmp_dir = var.windows_remove_tmp_dir != null ? var.windows_remove_tmp_dir : <<-EOT
  #   if (Test-Path ./.terraform/tmp/cloud-init) {
  #     Remove-Item ./.terraform/tmp/cloud-init -Recurse
  #   }
  # EOT

  # bash_remove_tmp_dir = var.bash_remove_tmp_dir != null ? var.bash_remove_tmp_dir : <<-EOT
  #     [ -d ./.terraform/tmp/cloud-init ] && rm -rf ./.terraform/tmp/cloud-init
  # EOT
}


resource "null_resource" "cloud-init" {
  for_each = var.cloud_init.content

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(var.cloud_init))
  }

  provisioner "local-exec" {
    command     = <<-EOT
    mkdir -p "${path.root}/.terraform/tmp/cloud-init"
    echo "${each.value}" > "${path.root}/.terraform/tmp/cloud-init/${each.key}"
    EOT
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }

}


resource "null_resource" "ISOHandler" {
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1      = sha1(jsonencode(var.cloud_init))
    is_windows         = local.is_windows
    windows_remove_iso = local.windows_remove_iso
    bash_remove_iso    = local.bash_remove_iso
  }

  depends_on = [
    null_resource.cloud-init
  ]

  # create iso file
  provisioner "local-exec" {
    command = local.is_windows ? local.windows_create_iso : local.bash_create_iso
  }

  # remove iso file
  provisioner "local-exec" {
    when        = destroy
    command     = self.triggers.is_windows ? self.triggers.windows_remove_iso : self.triggers.bash_remove_iso
    interpreter = self.triggers.is_windows ? ["Powershell", "-Command"] : []
  }
}


resource "null_resource" "deleteLocalFile" {
  triggers = {
    manifest_sha1 = sha1(jsonencode(var.cloud_init))
  }

  depends_on = [
    null_resource.ISOHandler,
  ]

  provisioner "local-exec" {
    command     = local.is_windows ? var.windows_remove_tmp_dir : var.bash_remove_tmp_dir
    interpreter = local.is_windows ? ["Powershell", "-Command"] : []
  }
}
