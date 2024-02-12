// https://github.com/hashicorp/vault/blob/main/.release/linux/package/etc/vault.d/vault.hcl
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/vault/docs/configuration

ui = true

#mlock = true
disable_mlock = true

// storage "file" {
//   path = "/opt/vault/data"
// }

// https://developer.hashicorp.com/vault/docs/configuration/storage/raft
storage "raft" {
  path = "${storage_path}"
  node_id = "${node_id}"
}

api_addr = "${api_addr}"
// https://developer.hashicorp.com/vault/docs/configuration#cluster_addr
cluster_addr = "${cluster_addr}"

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
  tls_cert_file = "${tls_cert_file}"
  tls_key_file  = "${tls_key_file}"
  tls_disable_client_certs = "${tls_disable_client_certs}"
}

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