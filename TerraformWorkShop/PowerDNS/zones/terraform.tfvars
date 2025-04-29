pdns = {
  api_key    = "powerdns"
  server_url = "http://192.168.255.10:8081"
}

zones = [
  {
    name        = "day0.sololab."
    nameservers = ["ns1.day0.sololab."]
    records = [
      {
        fqdn = "day0.sololab."
        type = "SOA"
        ttl  = 86400
        results = [
          "ns1.day0.sololab. day0.sololab. 2025042901 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day0.sololab."
        type = "A"
        ttl  = 86400
        results = [
          "192.168.255.10"
        ]
      },
      {
        fqdn = "zot.day0.sololab."
        type = "A"
        ttl  = 86400
        results = [
          "192.168.255.10"
        ]
      },
      {
        fqdn = "pdns-auth.day0.sololab."
        type = "A"
        ttl  = 86400
        results = [
          "192.168.255.10"
        ]
      },
      {
        fqdn = "pdns-recursor.day0.sololab."
        type = "A"
        ttl  = 86400
        results = [
          "192.168.255.10"
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
      # {
      #   fqdn = "etcd-0.day0.sololab."
      #   type = "A"
      #   ttl  = 86400
      #   results = [
      #     "192.168.255.10"
      #   ]
      # },
    ]
  },
  {
    name        = "day1.sololab."
    nameservers = ["ns1.day1.sololab."]
    records = [
      {
        fqdn = "day1.sololab."
        type = "SOA"
        ttl  = 86400
        results = [
          "ns1.day1.sololab. day1.sololab. 2025042901 3600 600 1814400 7200"
        ]
      },
      {
        fqdn = "ns1.day1.sololab."
        type = "A"
        ttl  = 86400
        results = [
          "192.168.255.20"
        ]
      },
    ]
  }
]
