resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/cockroach"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/cockroach"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/cockroach/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "cockroach" {
  depends_on = [
    null_resource.init,
  ]
  source = "../../modules/system-cockroachdb"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    # https://www.cockroachlabs.com/docs/releases/
    tar_file_source = "http://files.mgmt.sololab/releases/cockroach-v23.2.3.linux-amd64.tgz"
    tar_file_path   = "/home/vyos/cockroach-v23.2.3.linux-amd64.tgz"
    # tar -ztvf /home/vyos/cockroach-v23.2.3.linux-amd64.tgz
    tar_file_bin_path = "cockroach-v23.2.3.linux-amd64/cockroach"
    bin_file_dir      = "/usr/local/bin"
    tar_file_lib_path = "cockroach-v23.2.3.linux-amd64/lib"
    ext_lib_dir       = "/usr/local/lib/cockroach"
  }
  runas = {
    user        = "vyos"
    group       = "users"
    take_charge = false
  }
  config = {
    certs = {
      # https://www.cockroachlabs.com/docs/stable/authentication
      ca_cert_content = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      node_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_node_1", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
        # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ])
      node_key_content     = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_node_1", null)
      client_cert_basename = "client.root.crt"
      client_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_client_root", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
        # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ])
      client_key_basename = "client.root.key"
      client_key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_client_root", null)
      sub_dir             = "certs"
    }
    dir = "/etc/cockroach"
  }
}

module "cockroach_service" {
  depends_on = [module.cockroach]
  source     = "../../modules/system-systemd_service"
  service = {
    status  = "started"
    enabled = true
    systemd_service_unit = {
      content = templatefile("${path.root}/cockroach/cockroach.service", {
        user        = "vyos"
        group       = "users"
        listen_addr = "192.168.255.1:5432"
        http_addr   = "192.168.255.1:5443"
        certs_dir   = "/etc/cockroach/certs"
        store_path  = "/mnt/data/cockroach"
      })
      path = "/etc/systemd/system/cockroach.service"
    }
  }

}

module "cockroach_restart" {
  depends_on = [module.cockroach]
  source     = "../../modules/system-systemd_path"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    content = templatefile("${path.root}/cockroach/restart.path", {
      PathModified = [
        "/etc/systemd/system/cockroach.service",
      ]
      PathExistsGlob = [
        "/etc/cockroach/certs/*"
      ]
    })
    path = "/etc/systemd/system/cockroach_restart.path"
  }
  systemd_service_unit = {
    content = templatefile("${path.root}/cockroach/restart.service", {
      AssertPathExists = "/etc/systemd/system/cockroach.service"
      target_service   = "cockroach.service"
    })
    path = "/etc/systemd/system/cockroach_restart.service"
  }
}

locals {
  cockroach_post_process = {
    Set-TerraformBackend = {
      script_path = "${path.root}/cockroach/Set-TerraformBackend.sh"
      vars = {
        certs_dir   = "/etc/cockroach/certs"
        listen_addr = "192.168.255.1:5432"
      }
    }
  }
}

resource "null_resource" "cockroach_post_process" {
  depends_on = [
    module.cockroach,
  ]
  for_each = local.cockroach_post_process
  triggers = {
    script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
    host           = var.vm_conn.host
    port           = var.vm_conn.port
    user           = var.vm_conn.user
    password       = sensitive(var.vm_conn.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${each.value.script_path}", "${each.value.vars}")
    ]
  }
}

# resource "system_file" "cockroach_consul" {
#   depends_on = [
#     module.cockroach,
#   ]
#   path    = "/etc/consul.d/cockroach_consul.hcl"
#   content = file("${path.root}/cockroach/cockroach_consul.hcl")
#   user    = "vyos"
#   group   = "users"
# }
