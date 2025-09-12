prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://192.168.255.1:8081"
  insecure_https = true
}

zones = [
  {
    name        = "vyos.sololab."
    nameservers = ["ns1.vyos.sololab."]
    records = [
      {
        fqdn = "vyos.sololab."
        type = "SOA"
        ttl  = 60
        results = [
          "ns1.vyos.sololab. vyos.sololab. 2025042901 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.vyos.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "pdns-auth.vyos.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
    ]
  },
  {
    name        = "day0.sololab."
    nameservers = ["ns1.day0.sololab."]
    records = [
      {
        fqdn = "day0.sololab."
        type = "SOA"
        ttl  = 60
        results = [
          "ns1.day0.sololab. day0.sololab. 2025042901 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "zot.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "coredns.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "etcd-0.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      # {
      #   fqdn = "_etcd-server-ssl._tcp.day0.sololab."
      #   type = "SRV"
      #   ttl  = 3
      #   results = [
      #     "0 10 2380 etcd-0.day0.sololab.",
      #     # "0 10 2380 etcd-1.day0.sololab.",
      #     # "0 10 2380 etcd-2.day0.sololab.",
      #   ]
      # },
      {
        fqdn = "tfbackend-pg.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "traefik.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "cockpit.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "lldap.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "dufs.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "consul-client.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
    ]
  },
  {
    name        = "day1.sololab."
    nameservers = ["ns1.day1.sololab."]
    records = [
      {
        fqdn = "day1.sololab."
        type = "SOA"
        ttl  = 60
        results = [
          "ns1.day1.sololab. day1.sololab. 2025042901 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "vault.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "consul.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "traefik.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "nomad.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "minio-api.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
      {
        fqdn = "minio-console.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
    ]
  },
  {
    name        = "day2.sololab."
    nameservers = ["ns1.day2.sololab."]
    records = [
      {
        fqdn = "day2.sololab."
        type = "SOA"
        ttl  = 60
        results = [
          "ns1.day2.sololab. day2.sololab. 2025081301 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.1"
        ]
      },
    ]
  }
]

prov_remote = {
  host     = "192.168.255.1"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}


# post_process = {
#   "Enable-DDNSUpdate.sh" = {
#     script_path = "./Enable-DDNSUpdate.sh"
#     vars = {
#       PDNS_HOST        = "http://192.168.255.10:8081"
#       PDNS_API_KEY     = "powerdns"
#       ZONE_NAME        = "day0.sololab."
#       ZONE_FQDN        = "day0.sololab."
#       TSIG_KEY_NAME    = "dhcp-key"
#       TSIG_KEY_CONTENT = "AobsqQd3xT6oYFd51iayOwr/nz883CEndLc7NjCZj8kZ0v6GvWhGPF2etFrGmP7kTaiTBJXBJU5aFHqDycnbFg=="
#     }
#   }
# }
