# acl
// https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl-parameters
# https://developer.hashicorp.com/consul/tutorials/security-operations/docker-compose-auto-config
acl {
  enabled = true
  tokens {
    default = "${consul_token_client}"
  }
}
addresses {
  dns = "{{ GetInterfaceIP \"eth1\" }}"
}
auto_encrypt {
  tls = true
}
auto_reload_config = true
bind_addr          = "{{ GetInterfaceIP `eth1` }}" # 0.0.0.0 Listen on all IPv4
client_addr        = "{{ GetInterfaceIP `eth1` }}"
# data_dir             = "/consul/data"
disable_update_check = true
encrypt              = "${consul_encrypt_key}"
ports {
  https = 8501
}
retry_join = [
  "consul.day1.sololab"
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
