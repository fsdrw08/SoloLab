prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-otf-db"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day3"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 26
      gid = 26
    }
  },
]

jobs = [
  {
    path = "./attachments/otf-db.nomad.hcl"
  },
  {
    path = "./attachments/otf.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/config.env"
      },
    ]
  },
]
