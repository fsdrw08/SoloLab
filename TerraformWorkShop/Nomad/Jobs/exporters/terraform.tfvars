prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments-alloy/alloy.nomad.hcl"
    var_sets = [
      {
        name                = "alloy_config"
        value_template_path = "./attachments-alloy/config.alloy.hcl"
      }
    ]
  },
  {
    path = "./attachments-node-exporter/node-exporter.nomad.hcl"
  },
  {
    path = "./attachments-podman-exporter/podman-exporter.nomad.hcl"
  },
]
