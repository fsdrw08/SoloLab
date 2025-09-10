prov_etcd = {
  endpoints = "https://etcd-0.day0.sololab:2379"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

# https://coredns.io/plugins/etcd/
dns_records = [
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
    hostname = "vault.day1.sololab"
    value = {
      string_map = {
        host = "192.168.255.20"
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
        host = "192.168.255.20"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "minio-api.day1.sololab"
    value = {
      string_map = {
        host = "minio.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  {
    hostname = "minio-console.day1.sololab"
    value = {
      string_map = {
        host = "minio.service.consul"
      }
      number_map = {
        ttl = 60
      }
    }
  },
  # {
  #   hostname = "grafana.day1.sololab"
  #   value = {
  #     string_map = {
  #       host = "grafana.service.consul"
  #     }
  #     number_map = {
  #       ttl = 60
  #     }
  #   }
  # },
  # {
  #   hostname = "loki.day1.sololab"
  #   value = {
  #     string_map = {
  #       host = "loki-day1.service.consul"
  #     }
  #     number_map = {
  #       ttl = 60
  #     }
  #   }
  # },
]
