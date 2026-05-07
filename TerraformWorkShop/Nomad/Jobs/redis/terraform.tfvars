prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-redis"
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
      uid = 999
      gid = 1000
    }
  },
  {
    name = "hvol-redis-insight"
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
      uid = 1000
      gid = 1000
    }
  },
]

jobs = [
  {
    path = "./attachments-redis/redis.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments-redis/server.conf"
      }
    ]
  },
  {
    path = "./attachments-redis-insight/redis-insight.nomad.hcl"
  },
]
