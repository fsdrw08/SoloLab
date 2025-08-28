# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "whoami" {
  jobspec = file("${path.module}/attachments/whoami.nomad.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      install_config = file("${path.module}/attachments/install.whoami.yml")
      routing_config = file("${path.module}/attachments/routing.whoami.yml")
    }
  }

  purge_on_destroy = true
}

resource "powerdns_record" "records" {
  for_each = {
    for record in var.dns_records : record.name => record
  }
  zone    = each.value.zone
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
