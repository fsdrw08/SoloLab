# consul
resource "null_resource" "consul_bin" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command = local.is_windows ? join(";",
      [
        "curl.exe -s -o ${path.module}/consul.zip https://releases.hashicorp.com/consul/1.17.0/consul_1.17.0_linux_amd64.zip",
        "tar.exe -x -f ${path.module}/consul.zip",
        "mv ${path.module}/consul ${path.module}/consul.bin -force"
      ]
      ) : join(";",
      [
        "curl -s -o ${path.module}/minio.bin https://dl.min.io/server/minio/release/linux-amd64/minio",
        "tar -x -f ${path.module}/consul.zip --overwrite",
        "mv ${path.module}/consul ${path.module}/consul.bin"
      ]
    )
  }
}

data "null_data_source" "consul_bin" {
  inputs = {
    file = "${path.module}/consul.bin"
  }
}

resource "system_file" "consul_bin" {
  depends_on = [null_resource.consul_bin]
  path       = "/usr/bin/consul"
  source     = data.null_data_source.consul_bin.outputs.file
  mode       = 755
}

resource "system_file" "consul_config" {
  path    = "/etc/consul.d/consul.hcl"
  content = file("${path.module}/consul.hcl")
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /mnt/data/consul",
      "sudo chown vyos:users /mnt/data/consul",
    ]
  }
}

# resource "system_file" "consul_service" {
#   path = "/etc/systemd/system/consul.service"
#   content = templatefile("${path.module}/consul.service.tftpl", {
#     user  = "vyos",
#     group = "users",
#   })
# }
