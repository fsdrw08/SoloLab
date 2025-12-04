logging {
  level  = "info"
  format = "logfmt"
}

// https://github.com/narwhl/blueprint/blob/80786b13a4e0c0e0a5c53ddedf103af49e437eae/modules/nomad/templates/nomad.alloy.tftpl#L4
local.file_match "nomad_logs" {
  path_targets = [
    { __path__ = "/var/lib/nomad/alloc/*/alloc/logs/*.stdout.*", __path_exclude__ = "/var/lib/nomad/alloc/**/*.fifo" },
    { __path__ = "/var/lib/nomad/alloc/*/alloc/logs/*.stderr.*", __path_exclude__ = "/var/lib/nomad/alloc/**/*.fifo" },
  ]
}
loki.source.file "nomad_logs" {
  targets    = local.file_match.nomad_logs.targets
  forward_to = [loki.write.loki.receiver]
}

loki.write "loki" {
  endpoint {
    url = "https://loki.day1.sololab/loki/api/v1/push"
    tls_config {
      insecure_skip_verify = true
    }
  }
}