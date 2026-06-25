prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-gitea-runner"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day5"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 1000
      gid = 1000
    }
  },
]


jobs = [
  {
    path = "./attachments/gitea-runner.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/app.ini"
      },
    ]
  },
]
