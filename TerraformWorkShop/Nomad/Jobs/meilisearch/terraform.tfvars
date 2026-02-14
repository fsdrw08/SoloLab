prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/meilisearch.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/config.toml"
        value_template_vars = {
          "master_key" = "sBAYWAE2iVmK4UFYuNxryoK-GyIPe7swAUN2nCcnSqY"
        }
      },
    ]
  },
]
