prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "nexus-db"
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
    name      = "csi-nexus-cacerts"
    plugin_id = "juicefs"
    volume_id = "csi-nexus-cacerts"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      }
    ]
    secrets = {
      name = "csi-nexus-cacerts"
      # juicefs redis metadata engine use 1 whole logical database
      # (1 redis instance have 16 logical databases) for 1 file system
      # https://juicefs.com/docs/community/databases_for_metadata/#etcd
      # consider use etcd as metadata engine instead
      metaurl = "etcd://juicefs:juicefs@etcd-0.day1.sololab:2379/juicefs/nexus-cacerts/_?cacert=/secrets/tls/ca.crt"
      # https://juicefs.com/docs/community/reference/how_to_set_up_object_storage/#other-options
      bucket     = "https://dufs.day1.sololab/webdav/?tls-insecure-skip-verify=true"
      storage    = "webdav"
      access-key = "webdav"
      secret-key = "webdav"
    }
  },
  {
    name      = "csi-nexus-data"
    plugin_id = "juicefs"
    volume_id = "csi-nexus-data"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      }
    ]
    secrets = {
      name = "csi-nexus-data"
      # juicefs redis metadata engine use 1 whole logical database
      # (1 redis instance have 16 logical databases) for 1 file system
      # https://juicefs.com/docs/community/databases_for_metadata/#etcd
      # consider use etcd as metadata engine instead
      metaurl = "etcd://juicefs:juicefs@etcd-0.day1.sololab:2379/juicefs/nexus-data/_?cacert=/secrets/tls/ca.crt"
      # https://juicefs.com/docs/community/reference/how_to_set_up_object_storage/#other-options
      bucket     = "https://dufs.day1.sololab/webdav/?tls-insecure-skip-verify=true"
      storage    = "webdav"
      access-key = "webdav"
      secret-key = "webdav"
    }
  },
]

jobs = [
  {
    path = "./attachments/nexus-db.nomad.hcl"
  },
  {
    path = "./attachments/nexus.nomad.hcl"
    var_sets = [
      {
        name = "metrics_auth_header"
        # bWV0cmljczpQQHNzdzByZA== is the base64 encoding of "metrics:P@ssw0rd"
        value_plaintext = "Basic bWV0cmljczpQQHNzdzByZA=="
      },
    ]
  },
]
