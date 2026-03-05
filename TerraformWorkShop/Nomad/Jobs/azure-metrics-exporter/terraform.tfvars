prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "azure-metrics-forwarder"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day2"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      mode = "0755"
      uid  = 65534
      gid  = 65534
    }
  },
]

jobs = [
  {
    path = "./attachments/azure-metrics-exporter.nomad.hcl"
    var_sets = [
      {
        name                = "prometheus_config"
        value_template_path = "./attachments/prometheus.yml"
      }
    ]
  },
]
