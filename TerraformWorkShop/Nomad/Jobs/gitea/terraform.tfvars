prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-gitea-db"
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

csi_volumes = [
  {
    name      = "csi-gitea-data"
    plugin_id = "juicefs"
    volume_id = "csi-gitea-data"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      }
    ]
    secrets = {
      name = "csi-gitea-data"
      # juicefs redis metadata engine use 1 whole logical database
      # (1 redis instance have 16 logical databases) for 1 file system
      # https://juicefs.com/docs/community/databases_for_metadata/#create-a-file-system
      # https://juicefs.com/docs/community/databases_for_metadata/#etcd
      # consider use etcd as metadata engine instead
      metaurl = "etcd://juicefs:juicefs@etcd-0.day1.sololab:2379/juicefs/gitea-data/_?cacert=/secrets/tls/ca.crt"
      # https://juicefs.com/docs/zh/community/reference/how_to_set_up_object_storage/#other-options
      bucket     = "https://dufs.day1.sololab/webdav/?tls-insecure-skip-verify=true"
      storage    = "webdav"
      access-key = "admin"
      secret-key = "admin"
    }
  },
  {
    name      = "csi-gitea-config"
    plugin_id = "juicefs"
    volume_id = "csi-gitea-config"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      }
    ]
    secrets = {
      name    = "csi-gitea-config"
      metaurl = "etcd://juicefs:juicefs@etcd-0.day1.sololab:2379/juicefs/gitea-config/_?cacert=/secrets/tls/ca.crt"
      # https://juicefs.com/docs/zh/community/reference/how_to_set_up_object_storage/#other-options
      bucket     = "https://dufs.day1.sololab/webdav/?tls-insecure-skip-verify=true"
      storage    = "webdav"
      access-key = "admin"
      secret-key = "admin"
    }
  },
]

jobs = [
  {
    path = "./attachments/gitea-db.nomad.hcl"
  },
  {
    path = "./attachments/gitea.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/app.ini"
      },
    ]
  },
  # {
  #   path = "./attachments/gitea-admin.nomad.hcl"
  #   var_sets = [
  #     {
  #       name                = "config"
  #       value_template_path = "./attachments/app.ini"
  #     },
  #     {
  #       name                = "admin_script"
  #       value_template_path = "./attachments/gitea-admin.sh"
  #     },
  #   ]
  # }
]
