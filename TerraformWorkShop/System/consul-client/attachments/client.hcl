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
bind_addr            = "{{ GetInterfaceIP `eth0` }}" # 0.0.0.0 Listen on all IPv4
client_addr          = "0.0.0.0"
data_dir             = "/mnt/data/consul"
disable_update_check = true
encrypt              = "${consul_encrypt_key}"
ports {
  https = 8501
}
retry_join = [
  "${consul_server_fqdn}"
]
server = false
tls {
  defaults {
    ca_file                = "${tls_ca_file}"
    verify_incoming        = false
    verify_outgoing        = true
    verify_server_hostname = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}
