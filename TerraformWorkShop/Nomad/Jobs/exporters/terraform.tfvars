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
  {
    path = "./attachments-postgres-exporter/postgres-exporter.nomad.hcl"
    var_sets = [
      {
        name                = "postgresql_exporter_config"
        value_template_path = "./attachments-postgres-exporter/postgres_exporter.yaml"
      }
    ]
  },
  {
    path = "./attachments-redis-exporter/redis-exporter.nomad.hcl"
  },
]
