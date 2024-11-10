data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

resource "system_folder" "config" {
  path = "/etc/cockpit"
}

# https://cockpit-project.org/guide/latest/cockpit-tls.8
resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = "/etc/cockpit/ws-certs.d"
}


resource "system_file" "cert" {
  depends_on = [system_folder.certs]
  path       = "/etc/cockpit/ws-certs.d/cockpit.crt"
  content = join("", [
    lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockpit", null),
    data.terraform_remote_state.root_ca.outputs.int_ca_pem,
  ])
}

resource "system_file" "key" {
  depends_on = [system_folder.certs]
  path       = "/etc/cockpit/ws-certs.d/cockpit.key"
  content    = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockpit", null)
}

module "vyos_container" {
  depends_on = [
    system_file.cert,
    system_file.key,
  ]
  source   = "../../modules/vyos-container"
  vm_conn  = var.vm_conn
  network  = var.container.network
  workload = var.container.workload
}

resource "vyos_static_host_mapping" "host_mapping" {
  depends_on = [
    module.vyos_container,
  ]
  host = var.dns_record.host
  ip   = var.dns_record.ip
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
    vyos_static_host_mapping.host_mapping
  ]
  for_each = var.reverse_proxy
  path     = each.value.path
  configs  = each.value.configs
}
