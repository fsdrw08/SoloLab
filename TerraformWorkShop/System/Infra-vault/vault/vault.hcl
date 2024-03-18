// https://github.com/hashicorp/vault/blob/main/.release/linux/package/etc/vault.d/vault.hcl
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/vault/docs/configuration

ui = true

#mlock = true

// https://developer.hashicorp.com/vault/docs/configuration/storage/raft
// When using the Integrated Storage backend, it is strongly recommended to set disable_mlock to true, 
// and to disable memory swapping on the system.
disable_mlock = true

// storage "file" {
//   path = "/opt/vault/data"
// }

// https://developer.hashicorp.com/vault/docs/configuration/storage/raft
// https://www.velotio.com/engineering-blog/how-to-setup-hashicorp-vault-ha-cluster-with-integrated-storage-raft
storage "raft" {
  path = "${storage_path}"
  node_id = "${node_id}"
  // no need to add retry_join if there is only one node
  // retry_join {
  //   leader_api_addr = "${api_addr}"
  //   leader_ca_cert_file = "${tls_ca_file}"
  //   leader_client_cert_file = "${tls_cert_file}"
  //   leader_client_key_file = "${tls_key_file}"
  // }
}



#storage "consul" {
#  address = "127.0.0.1:8500"
#  path    = "vault"
#}

# HTTP listener
#listener "tcp" {
#  address = "127.0.0.1:8200"
#  tls_disable = 1
#}

# HTTPS listener
// https://developer.hashicorp.com/vault/docs/configuration/listener/tcp
listener "tcp" {
  address       = "${listener_address}"
  cluster_address = "${listener_cluster_address}"
  tls_cert_file = "${tls_cert_file}"
  tls_key_file  = "${tls_key_file}"
  tls_disable_client_certs = "${tls_disable_client_certs}"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  cluster_address = "127.0.0.1:8201"
  tls_cert_file = "${tls_cert_file}"
  tls_key_file  = "${tls_key_file}"
  tls_disable_client_certs = "${tls_disable_client_certs}"
}

// https://developer.hashicorp.com/vault/docs/configuration#api_addr
// Specifies the address (full URL) to advertise to other Vault servers in the cluster for client redirection. 
// This value is also used for plugin backends. This can also be provided via the environment variable VAULT_API_ADDR. 
// In general this should be set as a full URL that points to the value of the listener address. 
// This can be dynamically defined with a go-sockaddr template that is resolved at runtime.
api_addr = "${api_addr}"
// https://developer.hashicorp.com/vault/docs/concepts/ha#per-node-cluster-address
// Note: When using the Integrated Storage backend, it is required to provide 
// cluster_addr to indicate the address and port to be used for communication 
// between the nodes in the Raft cluster.
// https://developer.hashicorp.com/vault/docs/configuration#cluster_addr
// Similar to the api_addr, cluster_addr is the value that each node, if active, should advertise to the standbys to use for server-to-server communications, 
// and lives as a top-level value in the configuration file. 
// On each node, this should be set to a host name or IP address 
// that a standby can use to reach one of that node's cluster_address values set in the listener blocks, including port. 
// (Note that this will always be forced to https since only TLS connections are used between servers.)
cluster_addr = "${cluster_addr}"


log_level = "debug"
# Enterprise license_path
# This will be required for enterprise as of v1.8
#license_path = "/etc/vault.d/vault.hclic"

# Example AWS KMS auto unseal
#seal "awskms" {
#  region = "us-east-1"
#  kms_key_id = "REPLACE-ME"
#}

# Example HSM auto unseal
#seal "pkcs11" {
#  lib            = "/usr/vault/lib/libCryptoki2_64.so"
#  slot           = "0"
#  pin            = "AAAA-BBBB-CCCC-DDDD"
#  key_label      = "vault-hsm-key"
#  hmac_key_label = "vault-hsm-hmac-key"
#}