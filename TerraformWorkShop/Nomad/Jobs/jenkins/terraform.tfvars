prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

csi_volumes = [
  {
    name      = "jenkins"
    plugin_id = "nfs"
    volume_id = "jenkins"
    capabilities = [
      {
        access_mode     = "single-node-writer"
        attachment_mode = "file-system"
      }
    ]
    parameters = {
      server           = "day2.node.consul"
      share            = "/"
      mountPermissions = "777"
    }
    mount_options = {
      fs_type = "nfs"
    }
  }
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
