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
        fqdn = "ns1.day0.sololab."
        type = "A"
        ttl  = 86400
        results = [
          "192.168.255.10"
        ]
      },
    ]
  },
]
