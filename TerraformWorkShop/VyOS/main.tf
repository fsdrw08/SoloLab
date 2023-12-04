# resource "null_resource" "external_disk" {
#   connection {
#     type     = "ssh"
#     host     = var.vyos_conn.address
#     user     = var.vyos_conn.ssh_user
#     password = var.vyos_conn.ssh_password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo bash /tmp/Set-ExternalDisk.sh",
#     ]
#   }
# }

resource "vyos_config" "containerNetwork" {
  path = "container network containers"
  value = jsonencode({
    "prefix" = "172.16.0.0/24"
  })
}

# resource "null_resource" "container_Consul_image" {
#   connection {
#     type     = "ssh"
#     host     = var.vyos_conn.address
#     user     = var.vyos_conn.ssh_user
#     password = var.vyos_conn.ssh_password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo podman pull docker.io/bitnami/consul:latest",
#     ]
#   }
# }

# resource "null_resource" "container_Consul_volume" {
#   connection {
#     type     = "ssh"
#     host     = var.vyos_conn.address
#     user     = var.vyos_conn.ssh_user
#     password = var.vyos_conn.ssh_password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo mkdir -p /mnt/data/consul/data",
#       "sudo chmod 777 /mnt/data/consul/data",
#     ]
#   }
# }

resource "vyos_config" "container_Consul" {
  path = "container name consul"
  value = jsonencode({
    "image" = "docker.io/bitnami/consul:latest"
    "network" = {
      "containers" = {
        "address" = "172.16.0.20"
      }
    }
    "environment" = {
      "TZ"               = { "value" = "Asia/Shanghai" }
      "CONSUL_BIND_ADDR" = { "value" = "127.0.0.1" }
    }
    "port" = {
      "consul_rpc" = {
        "source"      = "8300"
        "destination" = "8300"
      }
      "consul_serf" = {
        "source"      = "8301"
        "destination" = "8301"
      }
      "consul_http" = {
        "source"      = "8500"
        "destination" = "8500"
      }
      "consul_dns" = {
        "source"      = "8600"
        "destination" = "8600"
      }
    }
    "volume" = {
      "consul_data" = {
        "source"      = "/mnt/data/consul/data"
        "destination" = "/bitnami"
      }
    }
  })
}

# resource "vyos_config" "container_Consul_nat" {
#   path = "nat destination rule 20"
#   value = jsonencode({
#     "description"       = "consul forward"
#     "inbound-interface" = "eth1"
#     "protocol"          = "tcp_udp"
#     "source" = {
#       "address" = "192.168.255.0/24"
#     }
#     "translation" = {
#       "address" = "172.16.0.10"
#     }
#   })
# }
