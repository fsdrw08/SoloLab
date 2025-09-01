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
  address = "127.0.0.1:8501"
  ca_file = "${ca_file}"
  ssl     = true
  token   = "${nomad_consul_acl_token}"
}

data_dir = "${data_dir}"

leave_on_interrupt = true
leave_on_terminate = true

plugin_dir = "${plugin_dir}"
# Podman driver plugin configuration
# Reference: https://developer.hashicorp.com/nomad/plugins/drivers/podman#plugin-options
plugin "nomad-driver-podman" {
  config {
    socket_path = "unix:///run/podman/podman.sock"
    volumes {
      enabled      = true
      selinuxlabel = "z"
    }
  }
}

ports {
  http = 4746
  rpc  = 4747
  serf = 4748
}

tls {
  http = true
  rpc  = true

  ca_file   = "${ca_file}"
  cert_file = "${cert_file}"
  key_file  = "${key_file}"

  # verify_server_hostname = true
  verify_https_client = true
}

vault {
  enabled               = true
  address               = "${vault_server_address}"
  ca_file               = "${ca_file}"
  jwt_auth_backend_path = "jwt-nomad"
}