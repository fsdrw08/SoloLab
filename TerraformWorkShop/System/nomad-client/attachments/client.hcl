client {
  enabled = true
  servers = ["${servers}"]
  # https://github.com/hashicorp/nomad/issues/2052#issuecomment-1509128012
  # https://github.com/hashicorp/nomad/pull/16827
  drain_on_shutdown {
    deadline           = "20s"
    ignore_system_jobs = true
  }
}

consul {
  address    = "${CONSUL_HTTP_ADDR}"
  ca_file    = "${ca_file}"
  ssl        = true
  verify_ssl = false
  token      = "${CONSUL_HTTP_TOKEN}"
}

data_dir = "${data_dir}"

leave_on_interrupt = true
leave_on_terminate = true

plugin_dir = "${plugin_dir}"
plugin "docker" {
  config {
    endpoint = "unix:///disable/docker.sock"
  }
}
# Podman driver plugin configuration
# Reference: https://developer.hashicorp.com/nomad/plugins/drivers/podman#plugin-options
plugin "nomad-driver-podman" {
  config {
    socket_path = "${podman_socket}"
    volumes {
      enabled      = true
      selinuxlabel = "z"
    }
  }
}

ports {
  http = 14646
  rpc  = 14647
  serf = 14648
}

# https://developer.hashicorp.com/nomad/docs/configuration/tls
tls {
  http = true
  rpc  = true

  ca_file   = "${ca_file}"
  cert_file = "${cert_file}"
  key_file  = "${key_file}"

  # verify_server_hostname = true
  verify_https_client = true
}

# https://developer.hashicorp.com/nomad/docs/configuration/vault#parameters-for-nomad-clients
vault {
  enabled               = true
  address               = "${vault_server_address}"
  ca_file               = "${ca_file}"
  jwt_auth_backend_path = "jwt-nomad"
}