prov_etcd = {
  endpoints = "https://etcd-0.day1.sololab:443"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

roles = [
  {
    name = "role_skydns"
    permissions = [
      {
        permission = "read"
        key        = "/skydns/"
      }
    ]
  },
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
    username = "skydns"
    password = "skydns"
    roles    = ["role_skydns"]
  },
  {
    username = "juicefs"
    password = "juicefs"
    roles    = ["role_juicefs"]
  },
]
