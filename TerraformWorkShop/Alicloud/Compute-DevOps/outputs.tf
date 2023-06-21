output "private_key" {
  value     = tls_private_key.gitlab_root.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = data.terraform_remote_state.internet.outputs.eip_addresses[1]
}
