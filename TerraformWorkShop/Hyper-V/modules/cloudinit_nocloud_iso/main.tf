locals {
  # https://stackoverflow.com/questions/52628749/set-terraform-default-interpreter-for-local-exec
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  tempDir    = uuid()
}

# output cloud-init content to temp folder
resource "null_resource" "cloud-init" {
  for_each = var.cloud_init.content

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(var.cloud_init))
  }

  provisioner "local-exec" {
    command     = <<-EOT
    mkdir -p "${path.root}/.terraform/tmp/${local.tempDir}"
    echo "${each.value}" > "${path.root}/.terraform/tmp/${local.tempDir}/${each.key}"
    EOT
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }

}


resource "null_resource" "ISOHandler" {
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1      = sha1(jsonencode(var.cloud_init))
    is_windows         = local.is_windows
    windows_remove_iso = var.windows_remove_iso
    bash_remove_iso    = var.bash_remove_iso
    isoPath            = var.cloud_init.path
  }

  depends_on = [
    null_resource.cloud-init
  ]

  # create iso file
  provisioner "local-exec" {
    command     = local.is_windows ? join(";", ["$tempDir=\"${local.tempDir}\"", "$isoPath=\"${var.cloud_init.path}\"", var.windows_create_iso]) : join(";", ["tempDir=\"${local.tempDir}\"", "isoPath=\"${var.cloud_init.path}\"", var.bash_create_iso])
    interpreter = local.is_windows ? ["Powershell", "-Command"] : []
  }

  # remove iso file
  provisioner "local-exec" {
    when        = destroy
    command     = self.triggers.is_windows ? join(";", ["$isoPath=\"${self.triggers.isoPath}\"", self.triggers.windows_remove_iso]) : join(";", ["isoPath=\"${self.triggers.isoPath}\"", self.triggers.bash_remove_iso])
    interpreter = self.triggers.is_windows ? ["Powershell", "-Command"] : []
  }
}

# remove temp folder
resource "null_resource" "deleteLocalFile" {
  triggers = {
    manifest_sha1 = sha1(jsonencode(var.cloud_init))
  }

  depends_on = [
    null_resource.ISOHandler,
  ]

  provisioner "local-exec" {
    command     = local.is_windows ? join(";", ["$tempDir=\"${local.tempDir}\"", var.windows_remove_tmp_dir]) : join(";", ["tempDir=\"${local.tempDir}\"", var.bash_remove_tmp_dir])
    interpreter = local.is_windows ? ["Powershell", "-Command"] : []
  }
}
