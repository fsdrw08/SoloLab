prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

csi_volumes = [
  # {
  #   name      = "csi-atlantis-data"
  #   plugin_id = "juicefs"
  #   volume_id = "csi-atlantis-data"
  #   capabilities = [
  #     {
  #       access_mode     = "multi-node-multi-writer"
  #       attachment_mode = "file-system"
  #     }
  #   ]
  #   secrets = {
  #     name = "csi-atlantis-data"
  #     # juicefs redis metadata engine use 1 whole logical database
  #     # (1 redis instance have 16 logical databases) for 1 file system
  #     # https://juicefs.com/docs/community/databases_for_metadata/#etcd
  #     # consider use etcd as metadata engine instead
  #     metaurl = "etcd://juicefs:juicefs@etcd-0.day1.sololab:2379/juicefs/atlantis-data/_?cacert=/secrets/tls/ca.crt"
  #     # https://juicefs.com/docs/zh/community/reference/how_to_set_up_object_storage/#other-options
  #     bucket     = "https://dufs.day1.sololab/webdav/?tls-insecure-skip-verify=true"
  #     storage    = "webdav"
  #     access-key = "webdav"
  #     secret-key = "webdav"
  #   }
  # },
]

dynamic_host_volumes = [
  {
    name = "hvol-atlantis"
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
      uid = 100
      gid = 1000
    }
  },
]

jobs = [
  {
    path = "./attachments/atlantis.nomad.hcl"
    var_sets = [
      {
        name                = "atlantis_config"
        value_template_path = "./attachments/config.yaml"
      },
      {
        name                = "repo_config"
        value_template_path = "./attachments/repos.yaml"
      },
      {
        name                = "terraform_config"
        value_template_path = "./attachments/.terraformrc"
      },
    ]
  },
]
