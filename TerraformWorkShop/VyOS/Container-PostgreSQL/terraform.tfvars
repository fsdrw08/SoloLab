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
  uid         = 26
  gid         = 26
  take_charge = false
}

data_dirs = "/mnt/data/postgresql"

config = {
  dir = "/etc/postgresql/conf"
  files = [{
    # ref: 
    # https://github.com/sclorg/postgresql-container/blob/master/examples/enable-ssl
    # https://github.com/raffaelespazzoli/openshift-enablement-exam/blob/96754466a509febbd4c8718dac29daba3e97640b/misc4.0/spicedb/charts/spicedb/templates/postgresql-deployment.yaml
    basename = "ssl.conf"
    content  = <<EOT
    ssl = on
    ssl_cert_file = '/opt/app-root/src/certs/tls.crt' # server certificate
    ssl_key_file =  '/opt/app-root/src/certs/tls.key' # server private key
    #ssl_ca_file                                   # trusted certificate authorities
    #ssl_crl_file                                  # certificates revoked by certificate authorities
    EOT
  }]
}

certs = {
  dir                         = "/etc/postgresql/certs"
  cert_content_tfstate_ref    = "../../TLS/RootCA/terraform.tfstate"
  cert_content_tfstate_entity = "postgresql"
}

container = {
  network = {
    create      = true
    name        = "postgresql"
    cidr_prefix = "172.16.1.0/24"
  }
  # https://quay.io/repository/fedora/postgresql-16
  workload = {
    name      = "postgresql"
    image     = "zot.day0.sololab/fedora/postgresql-16:20241127"
    pull_flag = "--tls-verify=false"

    # local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
    local_image = ""
    others = {
      "network postgresql address" = "172.16.1.10"
      "memory"                     = "1024"

      "environment TZ value"                        = "Asia/Shanghai"
      "environment POSTGRESQL_USER value"           = "terraform"
      "environment POSTGRESQL_PASSWORD value"       = "terraform"
      "environment POSTGRESQL_DATABASE value"       = "tfstate"
      "environment POSTGRESQL_ADMIN_PASSWORD value" = "P@ssw0rd"

      "volume postgresql_conf source"      = "/etc/postgresql/conf"
      "volume postgresql_conf destination" = "/opt/app-root/src/postgresql-cfg"

      "volume postgresql_cert source"      = "/etc/postgresql/certs"
      "volume postgresql_cert destination" = "/opt/app-root/src/certs"

      "volume postgresql_data source"      = "/mnt/data/postgresql"
      "volume postgresql_data destination" = "/var/lib/pgsql/data"

    }
  }
}

reverse_proxy = {
  sql_frontend = {
    path = "load-balancing haproxy service tcp5432"
    configs = {
      "listen-address" = "192.168.255.1"
      "port"           = "5432"
      "mode"           = "tcp"
      "backend"        = "postgresql_5432"
    }
  }
  sql_backend = {
    path = "load-balancing haproxy backend postgresql_5432"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.1.10"
      "server vyos port"    = "5432"
    }
  }
}

dns_records = [
  {
    host = "postgresql.day0.sololab"
    ip   = "192.168.255.1"
  },
]
