logging {
  level  = "info"
  format = "logfmt"
}

// https://github.com/langerma/langerma-ansible-hashicorp/blob/6b9c2de2e258ca95da3e216b5ac54ef3657c5df9/files/config.alloy#L363
discovery.consulagent "consulagent" {
  server = "127.0.0.1:8501"
  scheme = "https"
  tls_config {
    insecure_skip_verify  = true
  }
}

discovery.relabel "consulagent_relabel" {
  targets = discovery.consulagent.consulagent.targets

  rule {
    source_labels = ["__meta_consulagent_node"]
    regex         = constants.hostname
    action        = "keep"
  }

  rule {
    source_labels = ["__meta_consulagent_tags"]
    regex         = ".*,log,.*"
    action        = "keep"
  }

  rule {
    source_labels = ["__meta_consulagent_service_id"]
    regex         = "_nomad-task-([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-.*"
    target_label  = "task_id"
  }

  rule {
    source_labels = ["__meta_consulagent_service"]
    target_label  = "service_name"
  }

  rule {
    source_labels = ["__meta_consulagent_node"]
    target_label  = "host"
  }

  rule {
    source_labels = ["__meta_consulagent_service_id"]
    regex         = "_nomad-task-([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-.*"
    target_label  = "__path__"
    replacement   = "/var/lib/nomad/alloc/$1/alloc/logs/*std*.[0-9]*"
  }
}

// https://github.com/narwhl/blueprint/blob/80786b13a4e0c0e0a5c53ddedf103af49e437eae/modules/nomad/templates/nomad.alloy.tftpl#L4
local.file_match "file_match" {
  path_targets = discovery.relabel.consulagent_relabel.output
}

// https://grafana.com/docs/alloy/v1.11/reference/components/local/local.file_match/
loki.source.file "file" {
  targets    = local.file_match.file_match.targets
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