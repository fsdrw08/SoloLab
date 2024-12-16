vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

vyos_conn = {
  url = "https://vyos-api.day0.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

runas = {
  uid         = 953
  gid         = 953
  take_charge = false
}

data_dirs = "/mnt/data/powerdns"

certs = {
  cert_content_tfstate_ref    = "../../TLS/RootCA/terraform.tfstate"
  cert_content_tfstate_entity = "pdns"
}

config = {
  dir          = "/etc/powerdns/templates.d"
  entry_script = <<EOT
#!/bin/sh
if [ ! -f "/var/lib/powerdns/pdns.sqlite3" ]; then
    sqlite3 /var/lib/powerdns/pdns.sqlite3 < /usr/local/share/doc/pdns/schema.sqlite3.sql
fi

/usr/local/sbin/pdns_server-startup
  EOT
  files = [
    {
      # https://github.com/PowerDNS/pdns/blob/3dfd8e317e904c61aff15fff10a8932ea0b72a0f/docs/guides/basic-database.rst#L144
      basename = "locals.conf.j2"
      content  = <<EOT
local-port=1053
    EOT
    }
  ]
}

container = {
  network = {
    create      = true
    name        = "powerdns"
    cidr_prefix = "172.16.2.0/24"
  }
  # https://hub.docker.com/r/powerdns/pdns-auth-49/tags
  workload = {
    name      = "powerdns"
    image     = "zot.day0.sololab/powerdns/pdns-auth-49:4.9.2"
    pull_flag = "--tls-verify=false"

    # local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
    local_image = ""
    others = {
      "network powerdns address" = "172.16.2.10"
      "memory"                   = "1024"

      "environment TZ value"                = "Asia/Shanghai"
      "environment PDNS_AUTH_API_KEY value" = "powerdns"
      "environment TEMPLATE_FILES value"    = "locals.conf"
      "environment PNDS_DNSUPDATE value"    = "yes"

      # https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth
      # https://github.com/PowerDNS/pdns/blob/master/dockerdata/startup.py
      # https://github.com/PowerDNS/pdns/blob/master/dockerdata/pdns.conf
      # https://doc.powerdns.com/authoritative/settings.html#include-dir
      "volume pdns_tmpl source"      = "/etc/powerdns/templates.d"
      "volume pdns_tmpl destination" = "/etc/powerdns/templates.d"

      "volume pdns_data source"      = "/mnt/data/powerdns"
      "volume pdns_data destination" = "/var/lib/powerdns"

      "entrypoint" = "/usr/bin/tini -- /etc/powerdns/templates.d/entrypoint.sh"
    }
  }
}

reverse_proxy = {
  api_frontend = {
    path = "load-balancing haproxy service tcp8081"
    configs = {
      "listen-address"  = "192.168.255.1"
      "port"            = "8081"
      "mode"            = "tcp"
      "backend"         = "pdns_8081"
      "ssl certificate" = "pdns"
    }
  }
  api_backend = {
    path = "load-balancing haproxy backend pdns_8081"
    configs = {
      "mode"                = "http"
      "server pdns address" = "172.16.2.10"
      "server pdns port"    = "8081"
    }
  }
  web_frontend = {
    path = "load-balancing haproxy service tcp443 rule 20"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "pdns.day0.sololab"
      "set backend" = "pdns_web"
    }
  }
  web_backend = {
    path = "load-balancing haproxy backend pdns_web"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "192.168.255.1"
      "server vyos port"    = "8081"
    }
  }
}

dns_records = [
  {
    host = "pdns.day0.sololab"
    ip   = "192.168.255.1"
  },
]

dns_forwarding = {
  path = "service dns forwarding domain day1.sololab"
  configs = {
    "name-server 172.16.2.10 port" = "1053"
  }
}
