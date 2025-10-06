# acl
// https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl-parameters
# https://developer.hashicorp.com/consul/tutorials/security-operations/docker-compose-auto-config
acl {
  default_policy           = "deny"
  enable_token_persistence = true
  enabled                  = true
  tokens {
    agent                            = "${consul_token_init}"
    default                          = "${consul_token_default}"
    dns                              = "${consul_token_init}"
    config_file_service_registration = "${consul_token_client}"
    replication                      = "${consul_token_init}"
  }
}
addresses {
  dns = "{{ GetInterfaceIP \"eth1\" }}"
}
# auto_encrypt {
#   allow_tls = true
# }
auto_reload_config = true
bind_addr          = "{{ GetInterfaceIP `eth1` }}" # 0.0.0.0 Listen on all IPv4
bootstrap_expect   = 1
client_addr        = "{{ GetInterfaceIP `eth1` }}"
# data_dir             = "/consul/data"
datacenter           = "dcv"
disable_update_check = true
encrypt              = "${consul_encrypt_key}"
primary_datacenter   = "dc1"
ports {
  https = 8501
}
retry_join_wan = [
  "consul.day1.sololab"
]
server = true
tls {
  defaults {
    ca_file                = "${tls_ca_file}"
    cert_file              = "${tls_cert_file}"
    key_file               = "${tls_key_file}"
    verify_incoming        = false
    verify_outgoing        = true
    verify_server_hostname = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}
ui_config {
  content_path = "/ui/"
  enabled      = true
}