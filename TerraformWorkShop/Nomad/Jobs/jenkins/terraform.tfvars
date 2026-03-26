prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "jenkins"
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
      mode = "0755"
      uid  = 1000
      gid  = 1000
    }
  },
]

jobs = [
  {
    path = "./attachments/jenkins.nomad.hcl"
    var_sets = [
      {
        name                = "jenkins_plugins"
        value_template_path = "./attachments/plugins.txt"
      },
      {
        name                = "jcasc_config"
        value_template_path = "./attachments/jcasc_config.yaml"
      },
    ]
  },
]
