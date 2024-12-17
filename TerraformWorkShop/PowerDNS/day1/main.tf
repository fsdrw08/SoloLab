resource "powerdns_zone" "zone" {
  name = "day1.sololab."
  kind = "Native"
  nameservers = [
    "ns1.day1.sololab."
  ]
}

resource "powerdns_record" "ns1" {
  zone = powerdns_zone.zone.name
  name = "ns1.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.1"
  ]
}

resource "powerdns_record" "etcd_SRV" {
  zone = powerdns_zone.zone.name
  name = "_etcd-server-ssl._tcp.day1.sololab."
  type = "SRV"
  ttl  = 300
  records = [
    "0 10 2380 etcd-0.day1.sololab.",
    # "0 10 2380 etcd-1.day1.sololab.",
    # "0 10 2380 etcd-2.day1.sololab.",
  ]
}
