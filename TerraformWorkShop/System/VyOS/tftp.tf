resource "null_resource" "tftp_dir" {
  triggers = {
    script_content = filesha256("./tftp/Set-TFTP.sh")
    address        = var.tftp.address
    dir            = var.tftp.dir.path
    user           = var.tftp.dir.own_by.user
    group          = var.tftp.dir.own_by.group
  }
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      templatefile(
        "./tftp/Set-TFTP.sh",
        {
          address = var.tftp.address
          dir     = var.tftp.dir.path
          user    = var.tftp.dir.own_by.user
          group   = var.tftp.dir.own_by.group
        }
      )
    ]
  }
}
