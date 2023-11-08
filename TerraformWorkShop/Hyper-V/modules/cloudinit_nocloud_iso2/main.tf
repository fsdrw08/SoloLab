locals {
  # https://stackoverflow.com/questions/52628749/set-terraform-default-interpreter-for-local-exec
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  tempDir    = uuid()
}

# output cloud-init content to temp folder
resource "null_resource" "cloudinit_temp_file" {
  for_each = { for part in var.cloudinit_config.part : part.filename => part }

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(var.cloudinit_config))
  }

  provisioner "local-exec" {
    # https://developer.hashicorp.com/terraform/language/expressions/references#path-root
    # command     = <<-EOT
    # mkdir -p "${path.root}/.terraform/tmp/${local.tempDir}"
    # echo "${each.value.content}" > "${path.root}/.terraform/tmp/${local.tempDir}/${each.value.filename}"
    # EOT
    command = local.is_windows ? join(
      ";",
      ["$tempDir=\"${path.root}/.terraform/tmp/${local.tempDir}\"",
        "$content=@'\n${each.value.content}\n'@",
        "$filename=\"${each.value.filename}\"",
        var.windows_create_file
      ]) : join(";",
      ["$tempDir=\"${path.root}/.terraform/tmp/${local.tempDir}\"",
        "$content=\"${each.value.content}\"",
        "$filename=\"${each.value.filename}\"",
        var.bash_create_file
      ]
    )
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }

}


resource "null_resource" "ISOHandler" {
  # The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1      = sha1(jsonencode(var.cloudinit_config))
    is_windows         = local.is_windows
    windows_remove_iso = var.windows_remove_iso
    bash_remove_iso    = var.bash_remove_iso
    isoName            = var.cloudinit_config.isoName
  }

  depends_on = [
    null_resource.cloudinit_temp_file
  ]

  # create iso file
  provisioner "local-exec" {
    command     = local.is_windows ? join(";", ["$tempDir=\"${local.tempDir}\"", "$isoName=\"${var.cloudinit_config.isoName}\"", var.windows_create_iso]) : join(";", ["tempDir=\"${local.tempDir}\"", "isoName=\"${var.cloudinit_config.isoName}\"", var.bash_create_iso])
    interpreter = local.is_windows ? ["Powershell", "-Command"] : []
  }

  # remove iso file
  provisioner "local-exec" {
    when        = destroy
    command     = self.triggers.is_windows ? join(";", ["$isoName=\"${self.triggers.isoName}\"", self.triggers.windows_remove_iso]) : join(";", ["isoName=\"${self.triggers.isoName}\"", self.triggers.bash_remove_iso])
    interpreter = self.triggers.is_windows ? ["Powershell", "-Command"] : []
  }
}

# remove temp folder
resource "null_resource" "deleteLocalFile" {
  triggers = {
    manifest_sha1 = sha1(jsonencode(var.cloudinit_config))
  }

  depends_on = [
    null_resource.ISOHandler,
  ]

  provisioner "local-exec" {
    command     = local.is_windows ? join(";", ["$tempDir=\"${local.tempDir}\"", var.windows_remove_tmp_dir]) : join(";", ["tempDir=\"${local.tempDir}\"", var.bash_remove_tmp_dir])
    interpreter = local.is_windows ? ["Powershell", "-Command"] : []
  }
}
