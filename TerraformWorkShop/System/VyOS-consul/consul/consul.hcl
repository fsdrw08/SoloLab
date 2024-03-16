# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://www.consul.io/docs/agent/config

# datacenter
# This flag controls the datacenter in which the agent is running. If not provided,
# it defaults to "dc1". Consul has first-class support for multiple datacenters, but
# it relies on proper configuration. Nodes in the same datacenter should be on a
# single LAN.
datacenter = "dc1"

# data_dir
# This flag provides a data directory for the agent to store state. This is required
# for all agents. The directory should be durable across reboots. This is especially
# critical for agents that are running in server mode as they must be able to persist
# cluster state. Additionally, the directory must support the use of filesystem
# locking, meaning some types of mounted folders (e.g. VirtualBox shared folders) may
# not be suitable.
data_dir = "${data_dir}"

# client_addr
# The address to which Consul will bind client interfaces, including the HTTP and DNS
# servers. By default, this is "127.0.0.1", allowing only loopback connections. In
# Consul 1.0 and later this can be set to a space-separated list of addresses to bind
# to, or a go-sockaddr template that can potentially resolve to multiple addresses.
addresses{
  dns = "${dns_addr}"
}
client_addr = "${client_addr}"

ports{
  dns = 53
  https = 8501
}

# ui
# Enables the built-in web UI server and the required HTTP routes. This eliminates
# the need to maintain the Consul web UI files separately from the binary.
# Version 1.10 deprecated ui=true in favor of ui_config.enabled=true
ui_config{
  enabled = true
}

# server
# This flag is used to control if an agent is in server or client mode. When provided,
# an agent will act as a Consul server. Each Consul cluster must have at least one
# server and ideally no more than 5 per datacenter. All servers participate in the Raft
# consensus algorithm to ensure that transactions occur in a consistent, linearizable
# manner. Transactions modify cluster state, which is maintained on all server nodes to
# ensure availability in the case of node failure. Server nodes also participate in a
# WAN gossip pool with server nodes in other datacenters. Servers act as gateways to
# other datacenters and forward traffic as appropriate.
server = true

# Bind addr
# You may use IPv4 or IPv6 but if you have multiple interfaces you must be explicit.
#bind_addr = "[::]" # Listen on all IPv6
bind_addr = "${bind_addr}" # 0.0.0.0 Listen on all IPv4
#
# Advertise addr - if you want to point clients to a different address than bind or LB.
#advertise_addr = "127.0.0.1"

# Enterprise License
# As of 1.10, Enterprise requires a license_path and does not have a short trial.
#license_path = "/etc/consul.d/consul.hclic"

# bootstrap_expect
# This flag provides the number of expected servers in the datacenter. Either this value
# should not be provided or the value must agree with other servers in the cluster. When
# provided, Consul waits until the specified number of servers are available and then
# bootstraps the cluster. This allows an initial leader to be elected automatically.
# This cannot be used in conjunction with the legacy -bootstrap flag. This flag requires
# -server mode.
bootstrap_expect=1

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

enable_local_script_checks = ${enable_local_script_checks}
# retry_join
# Similar to -join but allows retrying a join until it is successful. Once it joins
# successfully to a member in a list of members it will never attempt to join again.
# Agents will then solely maintain their membership via gossip. This is useful for
# cases where you know the address will eventually be available. This option can be
# specified multiple times to specify multiple agents to join. The value can contain
# IPv4, IPv6, or DNS addresses. In Consul 1.1.0 and later this can be set to a go-sockaddr
# template. If Consul is running on the non-default Serf LAN port, this must be specified
# as well. IPv6 must use the "bracketed" syntax. If multiple values are given, they are
# tried and retried in the order listed until the first succeeds. Here are some examples:
#retry_join = ["consul.domain.internal"]
#retry_join = ["10.0.4.67"]
#retry_join = ["[::1]:8301"]
#retry_join = ["consul.domain.internal", "10.0.4.67"]
# Cloud Auto-join examples:
# More details - https://www.consul.io/docs/agent/cloud-auto-join
#retry_join = ["provider=aws tag_key=... tag_value=..."]
#retry_join = ["provider=azure tag_name=... tag_value=... tenant_id=... client_id=... subscription_id=... secret_access_key=..."]
#retry_join = ["provider=gce project_name=... tag_value=..."]

# general
auto_reload_config = true

# tls
# https://developer.hashicorp.com/consul/tutorials/production-deploy/deployment-guide#tls-configuration
# https://developer.hashicorp.com/consul/docs/agent/config/config-files#tls-configuration-reference
# https://developer.hashicorp.com/consul/docs/connect/ca#root-certificate-rotation
# not recommend to set the "default" block, consul need a special CA to sign client agent 
# for service mesh, but https cert is a different thing, the "default" block will combine
# all together, if so, when change the cert and key in default block, seems will make the 
# agent cert changed, it will cause server agent dose not trust the client any more, to fix
# that, we have to update the consul build in CA cert and key to make it trigger Root Cerficate Rotation
# https://discuss.hashicorp.com/t/puzzled-with-ca-certs/43351/2

tls {
  defaults {
    ca_file = "${tls_ca_file}"
    cert_file = "${tls_cert_file}"
    key_file = "${tls_key_file}"
    verify_incoming = ${tls_verify_incoming}
    verify_outgoing = ${tls_verify_outgoing}
  }
  internal_rpc {
    verify_server_hostname = ${tls_irpc_verify_server_hostname}
  }
}

# Service Mesh Parameters
# by default, consul use it's build-in CA to generate root cert and key,
# then sign client
# https://developer.hashicorp.com/consul/docs/connect/ca#root-certificate-rotation
# https://developer.hashicorp.com/consul/docs/agent/config/config-files#service-mesh-parameters
# https://developer.hashicorp.com/consul/docs/connect/ca/consul#configuration
connect {
  enabled = ${connect_enabled}
}

// # https://developer.hashicorp.com/consul/tutorials/security/tls-encryption-secure
// auto_encrypt {
//   allow_tls = true
// }

# https://developer.hashicorp.com/consul/tutorials/security-operations/docker-compose-auto-config
# https://developer.hashicorp.com/consul/docs/agent/config/config-files#auto_config
auto_config {
  authorization = {
    enabled = true
    static = {
      oidc_discovery_url = "${auto_config_oidc_discovery_url}"
      oidc_discovery_ca_cert = "${auto_config_oidc_discovery_ca_cert}"
      bound_issuer = "${auto_config_bound_issuer}"
      bound_audiences = ["consul-cluster-dc1"]
      claim_mappings = {
        "/consul/hostname" = "node_name"
      }
      claim_assertions = [
        "value.node_name == \"$${node}\""
      ]
    }
  }
}

# acl
// https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl-parameters
# https://developer.hashicorp.com/consul/tutorials/security-operations/docker-compose-auto-config
acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    initial_management = "${acl_token_init_mgmt}"
    agent = "${acl_token_agent}"
    config_file_service_registration = "${acl_token_config_file_svc_reg}"
  }
}