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

leave_on_interrupt = true
leave_on_terminate = true
data_dir           = "${data_dir}"

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