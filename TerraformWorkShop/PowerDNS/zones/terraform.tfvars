prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://pdns-auth.day0.sololab"
  insecure_https = true
}

zones = [
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
          "192.168.255.2"
        ]
      },
      {
        fqdn = "cockpit.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "prometheus-node-exporter.day0.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
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
          "192.168.255.2"
        ]
      },
      # {
      #   fqdn = "_etcd-server-ssl._tcp.day1.sololab."
      #   type = "SRV"
      #   ttl  = 3
      #   results = [
      #     "0 10 2380 etcd-0.day1.sololab.",
      #     # "0 10 2380 etcd-1.day1.sololab.",
      #     # "0 10 2380 etcd-2.day1.sololab.",
      #   ]
      # },
      {
        fqdn = "etcd-0.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "coredns.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "traefik.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "lldap.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "dex.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "vault.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "zot.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "tfbackend-pg.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.10"
        ]
      },
      {
        fqdn = "cockpit.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "dufs.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "minio-api.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "minio-console.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "prometheus-podman-exporter.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "alloy.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "whoami.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "consul-client.day1.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
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
          "ns1.day2.sololab. day2.sololab. 2025042901 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "consul.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "traefik.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "nomad.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "grafana.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "loki.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "prometheus.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "prometheus-blackbox-exporter.day2.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
    ]
  },
  {
    name        = "day3.sololab."
    nameservers = ["ns1.day3.sololab."]
    records = [
      {
        fqdn = "day3.sololab."
        type = "SOA"
        ttl  = 60
        results = [
          "ns1.day3.sololab. day3.sololab. 2025081301 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day3.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "traefik.day3.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "pgweb.day3.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "redis-insight.day3.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "meilisearch.day3.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
    ]
  },
  {
    name        = "day4.sololab."
    nameservers = ["ns1.day4.sololab."]
    records = [
      {
        fqdn = "day4.sololab."
        type = "SOA"
        ttl  = 60
        results = [
          "ns1.day4.sololab. day4.sololab. 2025081301 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "traefik.day4.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "gitea.day4.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "otf.day4.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "nexus.day4.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
      {
        fqdn = "jenkins.day4.sololab."
        type = "A"
        ttl  = 60
        results = [
          "192.168.255.2"
        ]
      },
    ]
  }
]

# prov_remote = {
#   host     = "192.168.255.1"
#   port     = 22
#   user     = "podmgr"
#   password = "podmgr"
# }


# post_process = {
#   "Enable-DDNSUpdate.sh" = {
#     script_path = "./Enable-DDNSUpdate.sh"
#     vars = {
#       PDNS_HOST        = "http://192.168.255.10:8081"
#       PDNS_API_KEY     = "powerdns"
#       ZONE_NAME        = "day1.sololab."
#       ZONE_FQDN        = "day1.sololab."
#       TSIG_KEY_NAME    = "dhcp-key"
#       TSIG_KEY_CONTENT = "AobsqQd3xT6oYFd51iayOwr/nz883CEndLc7NjCZj8kZ0v6GvWhGPF2etFrGmP7kTaiTBJXBJU5aFHqDycnbFg=="
#     }
#   }
# }
