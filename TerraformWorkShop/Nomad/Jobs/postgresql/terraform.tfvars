prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/postgresql.nomad.hcl"
    var_sets = [
      {
        name                = "postgresql_config"
        value_template_path = "./attachments/postgresql.ini"
      }
    ]
  },
]
