prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

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
