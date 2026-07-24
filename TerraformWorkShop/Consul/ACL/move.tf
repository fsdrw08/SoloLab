moved {
  # consul_dns
  from = consul_acl_role.role["consul_dns"]
  to   = consul_acl_role.role["63e8c3e9"]
}
moved {
  # consul_client
  from = consul_acl_role.role["consul_client"]
  to   = consul_acl_role.role["685da2a6"]
}
moved {
  # nomad_server
  from = consul_acl_role.role["nomad_server"]
  to   = consul_acl_role.role["11e19d4c"]
}
moved {
  # nomad_client
  from = consul_acl_role.role["nomad_client"]
  to   = consul_acl_role.role["95eaad9e"]
}
moved {
  # prometheus
  from = consul_acl_role.role["prometheus"]
  to   = consul_acl_role.role["1f88bc0c"]
}
moved {
  # tf_backend
  from = consul_acl_role.role["tf_backend"]
  to   = consul_acl_role.role["a65dab9e"]
}

moved {
  # consul_dns
  from = consul_acl_token.token["consul_dns"]
  to   = consul_acl_token.token["63e8c3e9"]
}
moved {
  # consul_client
  from = consul_acl_token.token["consul_client"]
  to   = consul_acl_token.token["685da2a6"]
}
moved {
  # nomad_server
  from = consul_acl_token.token["nomad_server"]
  to   = consul_acl_token.token["11e19d4c"]
}
moved {
  # nomad_client
  from = consul_acl_token.token["nomad_client"]
  to   = consul_acl_token.token["95eaad9e"]
}
moved {
  # prometheus
  from = consul_acl_token.token["prometheus"]
  to   = consul_acl_token.token["1f88bc0c"]
}
moved {
  # tf_backend
  from = consul_acl_token.token["tf_backend"]
  to   = consul_acl_token.token["a65dab9e"]
}

moved {
  # consul_dns
  from = vault_kv_secret_v2.secret["consul_dns"]
  to   = vault_kv_secret_v2.secret["63e8c3e9"]
}
moved {
  # consul_client
  from = vault_kv_secret_v2.secret["consul_client"]
  to   = vault_kv_secret_v2.secret["685da2a6"]
}
moved {
  # nomad_server
  from = vault_kv_secret_v2.secret["nomad_server"]
  to   = vault_kv_secret_v2.secret["11e19d4c"]
}
moved {
  # nomad_client
  from = vault_kv_secret_v2.secret["nomad_client"]
  to   = vault_kv_secret_v2.secret["95eaad9e"]
}
moved {
  # prometheus
  from = vault_kv_secret_v2.secret["prometheus"]
  to   = vault_kv_secret_v2.secret["1f88bc0c"]
}
moved {
  # tf_backend
  from = vault_kv_secret_v2.secret["tf_backend"]
  to   = vault_kv_secret_v2.secret["a65dab9e"]
}
