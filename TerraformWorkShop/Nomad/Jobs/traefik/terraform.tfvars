prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/traefik.nomad.hcl"
    var_sets = [
      {
        name                = "install_config"
        value_template_path = "./attachments/install.traefik.yml"
      },
      {
        name                = "routing_config"
        value_template_path = "./attachments/routing.traefik.yml"
      }
    ]
  },
]
