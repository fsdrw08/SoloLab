prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/pgbouncer.nomad.hcl"
    var_sets = [
      {
        name                = "pgbouncer_config"
        value_template_path = "./attachments/pgbouncer.ini"
      }
    ]
  },
]
