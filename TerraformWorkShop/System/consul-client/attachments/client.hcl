# acl
// https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl-parameters
# https://developer.hashicorp.com/consul/tutorials/security-operations/docker-compose-auto-config
acl {
  enabled = true
  tokens {
    default = "${acl_token_default}"
  }
}

auto_encrypt {
  tls = true
}

auto_reload_config = true

# Bind addr
# You may use IPv4 or IPv6 but if you have multiple interfaces you must be explicit.
#bind_addr = "[::]" # Listen on all IPv6
bind_addr = "${bind_addr}" # 0.0.0.0 Listen on all IPv4

client_addr = "0.0.0.0"

disable_update_check = true

# encrypt
# Specifies the secret key to use for encryption of Consul network traffic. This key must
# be 32-bytes that are Base64-encoded. The easiest way to create an encryption key is to
# use consul keygen. All nodes within a cluster must share the same encryption key to
# communicate. The provided key is automatically persisted to the data directory and loaded
# automatically whenever the agent is restarted. This means that to encrypt Consul's gossip
# protocol, this option only needs to be provided once on each agent's initial startup
# sequence. If it is provided after Consul has been initialized with an encryption key,
# then the provided key is ignored and a warning will be displayed.
encrypt = "${encrypt}"

ports {
  https = 18501
  dns   = 53
}

retry_join = [
  "${retry_join}"
]

server = false

tls {
  defaults {
    ca_file                = "${tls_ca_file}"
    verify_incoming        = "${tls_verify_incoming}"
    verify_outgoing        = "${tls_verify_outgoing}"
    verify_server_hostname = "${tls_irpc_verify_server_hostname}"
  }
  internal_rpc {
    verify_server_hostname = "${tls_irpc_verify_server_hostname}"
  }
}

ui_config {
  content_path = "/ui"
  enabled      = true
}
