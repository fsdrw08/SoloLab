# persist CockroachDB systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u CockroachDB.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "service" {
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
