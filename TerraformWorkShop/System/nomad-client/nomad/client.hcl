client {
  enabled = true
  servers = ["${NOMAD_SERVERS}"]
}
data_dir = "${NOMAD_DATA_DIR}"
ports {
  http = 4746
  rpc  = 4747
  serf = 4748
}
tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.d/nomad-ca.pem"
  cert_file = "/etc/nomad.d/client.pem"
  key_file  = "/etc/nomad.d/client-key.pem"

  # verify_server_hostname = true
  verify_https_client = true
}