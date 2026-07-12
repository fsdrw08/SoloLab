prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-gitea-runner-cache"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day4"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 0
      gid = 0
    }
  },
  {
    name = "hvol-gitea-runner"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "regexp"
        value     = "^day5.*"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 0
      gid = 0
    }
  },
]


jobs = [
  {
    path = "./attachments/gitea-runner-cache.nomad.hcl"
  },
  {
    path = "./attachments/gitea-runner.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/config.yaml"
      },
    ]
  },
]
