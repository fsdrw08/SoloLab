prov_etcd = {
  endpoints = "https://etcd-0.day1.sololab:443"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

roles = [
  {
    name = "role_juicefs"
    permissions = [
      {
        permission = "readwrite"
        key        = "/juicefs/"
      }
    ]
  },
]

users = [
  {
    username = "juicefs"
    password = "juicefs"
    roles    = ["role_juicefs"]
  },
]
