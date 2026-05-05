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
    hostname = "alloy.day2.sololab"
    value = {
      string_map = {
        host = "alloy-day2.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "consul.day2.sololab"
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
    hostname = "traefik.day2.sololab"
    value = {
      string_map = {
        host = "traefik-day2.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "nomad.day2.sololab"
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
    hostname = "grafana.day2.sololab"
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
    hostname = "loki.day2.sololab"
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
    hostname = "prometheus.day2.sololab"
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
    hostname = "prometheus-blackbox-exporter.day2.sololab"
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
    hostname = "prometheus-consul-exporter.day2.sololab"
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
    hostname = "prometheus-podman-exporter.day2.sololab"
    value = {
      string_map = {
        host = "prometheus-podman-exporter-day2.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "prometheus-node-exporter.day2.sololab"
    value = {
      string_map = {
        host = "prometheus-node-exporter-day2.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "traefik.day3.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "pgweb.day3.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "redis-insight.day3.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "meilisearch.day3.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "traefik.day4.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "gitblit.day4.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "nexus.day4.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "jenkins.day4.sololab"
    value = {
      string_map = {
        host = "day2.node.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
]
