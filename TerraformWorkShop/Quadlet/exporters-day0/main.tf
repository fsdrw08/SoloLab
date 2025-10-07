module "podman_quadlet" {
  source  = "../../modules/system-systemd_quadlet"
  vm_conn = var.prov_remote
  podman_quadlet = {
    files = flatten([
      for unit in var.podman_quadlet.units : [
        for file in unit.files :
        {
          content = templatefile(
            file.template,
            file.vars
          )
          path = join("/", [
            var.podman_quadlet.dir,
            join(".", [
              unit.service.name,
              split(".", basename(file.template))[1]
            ])
          ])
        }
      ]
    ])
    services = [
      for unit in var.podman_quadlet.units : unit.service == null ? null :
      {
        name   = unit.service.name
        status = unit.service.status
        # custom_trigger = md5(remote_file.podman_kubes[unit.service.name].content)
      }
    ]
  }
}

resource "remote_file" "consul_service" {
  depends_on = [module.podman_quadlet]
  for_each = toset([
    "./attachments/podman-exporter.consul.hcl",
  ])
  path    = "/var/home/podmgr/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
