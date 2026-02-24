prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/nexus3.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/nexus3.properties"
      },
    ]
  },
]
