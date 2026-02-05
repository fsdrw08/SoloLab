prov_etcd = {
  endpoints = "https://etcd-0.day0.sololab:443"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

# https://coredns.io/plugins/etcd/
dns_records = [
  {
    hostname = "traefik.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "lldap.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "dex.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "tfbackend-pg.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "cockpit.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "dufs.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "minio-api.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "minio-console.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-podman-exporter.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-node-exporter.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "consul-client.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "alloy.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "vault.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "consul.day1.sololab"
    value = {
      string_map = {
        host = "consul.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "traefik.day1.sololab"
    value = {
      string_map = {
        host = "traefik-day1.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "nomad.day1.sololab"
    value = {
      string_map = {
        host = "nomad.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "grafana.day1.sololab"
    value = {
      string_map = {
        host = "grafana.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "loki.day1.sololab"
    value = {
      string_map = {
        host = "loki.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus.day1.sololab"
    value = {
      string_map = {
        host = "prometheus.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "redis-insight.day2.sololab"
    value = {
      string_map = {
        host = "redis-insight.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-blackbox-exporter.day1.sololab"
    value = {
      string_map = {
        host = "prometheus-blackbox-exporter.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-consul-exporter.day1.sololab"
    value = {
      string_map = {
        host = "prometheus-consul-exporter.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-podman-exporter.day1.sololab"
    value = {
      string_map = {
        host = "prometheus-podman-exporter-day1.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-node-exporter.day1.sololab"
    value = {
      string_map = {
        host = "prometheus-node-exporter-day1.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "traefik.day2.sololab"
    value = {
      string_map = {
        host = "day1.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "pgweb.day2.sololab"
    value = {
      string_map = {
        host = "day1.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
]
