prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/redis.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/server.conf"
      }
    ]
  },
]
