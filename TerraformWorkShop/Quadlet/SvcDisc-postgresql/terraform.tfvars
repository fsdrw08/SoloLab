prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

certs_ref = {
  tfstate = {
    backend = "local"
    config = {
      path = "../../TLS/RootCA/terraform.tfstate"
    }
    entity = "postgresql"
  }
  config_node = {
    cert = "postgresql.ssl.contents.\"tls\\.crt\""
    key  = "postgresql.ssl.contents.\"tls\\.key\""
  }
}

podman_kube = {
  helm = {
    name       = "keycloakdb"
    chart      = "../../../HelmWorkShop/helm-charts/charts/postgresql"
    value_file = "./podman-postgresql/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/keycloakdb-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-postgresql/keycloakdb-container.kube"
      # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      vars = {
        Description   = "PostgreSQL is a powerful, open source object-relational database system"
        Documentation = "https://www.postgresql.org/"
        yaml          = "keycloakdb-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
  ]
  service = {
    name   = "keycloakdb-container"
    status = "start"
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "keycloak-pgsql.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
