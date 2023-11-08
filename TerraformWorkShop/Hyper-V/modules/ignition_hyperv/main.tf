locals {
  # https://stackoverflow.com/questions/52628749/set-terraform-default-interpreter-for-local-exec
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  tempDir    = uuid()
}

# create ignition temp file in local
resource "null_resource" "ignition_temp_file" {
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(var.ignition_content))
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
        "$content=@'\n${var.ignition_content}\n'@",
        "$filename=\"ignition.ign\"",
        var.windows_create_file
      ]) : join(";",
      ["$tempDir=\"${path.root}/.terraform/tmp/${local.tempDir}\"",
        "$content=\"${var.ignition_content}\"",
        "$filename=\"ignition.ign\"",
        var.bash_create_file
      ]
    )
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }

}

# copy ignition file and run kvpctl.exe in remote hyper-v host
resource "null_resource" "IgnHandler" {
  # The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(var.ignition_content))
    # provisioner only accept vars from local block
    vhd_dir = var.vhd_dir
    vm_name = var.vm_name
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    host     = var.hyperv_host
    port     = var.hyperv_port
    user     = var.hyperv_user
    password = sensitive(var.hyperv_password)
  }

  # config winrm connection
  connection {
    type     = "winrm"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
    use_ntlm = true
    https    = true
    insecure = true
    timeout  = "20s"
  }

  # copy to remote
  provisioner "file" {
    source = module.cloudinit_nocloud_iso[count.index].isoName
    # destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\${each.key}\\cloud-init.iso"
    destination = join("/", ["${self.triggers.vhd_dir}", "${self.triggers.vm_name}\\${self.triggers.isoName}"])
  }
  provisioner "remote-exec" {
    # inline = [var.cmd_kvpctl]
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
    manifest_sha1 = sha1(jsonencode(var.ignition_content))
  }

  depends_on = [
    null_resource.ISOHandler,
  ]

  provisioner "local-exec" {
    command     = local.is_windows ? join(";", ["$tempDir=\"${local.tempDir}\"", var.windows_remove_tmp_dir]) : join(";", ["tempDir=\"${local.tempDir}\"", var.bash_remove_tmp_dir])
    interpreter = local.is_windows ? ["Powershell", "-Command"] : []
  }
}
