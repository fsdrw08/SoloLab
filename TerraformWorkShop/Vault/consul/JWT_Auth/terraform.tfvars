prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_key = {
  name             = "consul"
  algorithm        = "RS256"
  verification_ttl = 3600
  rotation_period  = 3600
}

oidc_roles = [
  {
    name = "consul-auto_config"
    ttl  = 3600
    # The value for matching the aud field of the JSON web token (JWT).
    # need to set the same value in Consul config file auto_config.authorization.static.bound_audiences
    # ref: https://developer.hashicorp.com/consul/tutorials/archive/docker-compose-auto-config#bound_audiences
    client_id = "consul-cluster-dc1"
    template  = <<-EOT
    {
      "consul": {
        "hostname": {{identity.entity.metadata.consul_agent}}
      }
    }
    EOT
  },
  # {
  #   name = "consul-jwt_auth"
  #   ttl  = 3600
  #   # The value for matching the aud field of the JSON web token (JWT)
  #   # need to set the same value in consul consul_acl_auth_method config_json.BoundAudiences
  #   # ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf
  #   client_id = "consul-jwt-auth"
  #   template  = <<EOT
  #   {
  #     "username": {{identity.entity.name}},
  #     "groups": {{identity.entity.groups.names}}
  #   }
  #   EOT
  # }
]

policy_bindings = [
  # config policy to make the user who permission granted allow to config meta data in it's own
  {
    policy_name     = "consul-auto_config"
    policy_content  = <<-EOT
      path "identity/oidc/token/consul-auto_config" {
        capabilities = ["read"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity/id/{{identity.entity.id}}" {
        capabilities = ["read", "update"]
      }
      
      # 允许读取和列出 kvv2/jwt 下的所有 secret 的数据
      path "kvv2/jwt/data/*" {
        capabilities = ["list", "read"]
      }
      # 允许列出 kvv2/jwt 下的所有 secret 的元数据，这对于获取 secret 的列表很有用。
      path "kvv2/jwt/metadata/*" {
        capabilities = ["list", "read"]
      }
      # 允许更新 kvv2/jwt 下的 secret 数据。
      path "kvv2/jwt/data/" {
        capabilities = ["update"]
      }
      EOT
    policy_group    = "Policy-Consul-Auto_Config"
    external_groups = ["app-consul-auto_config"]
  },
  # config policy to make the user who permission granted allow to config meta data in it's own
  # {
  #   policy_name     = "consul-jwt_auth"
  #   policy_content  = <<-EOT
  #     path "identity/oidc/token/consul-jwt_auth" {
  #       capabilities = ["read"]
  #     }
  #     path "identity/entity/id" {
  #       capabilities = ["list"]
  #     }
  #     path "identity/entity/id/{{identity.entity.id}}" {
  #       capabilities = ["read", "update"]
  #     }
  #     EOT
  #   policy_group    = "Policy-Consul-JWT_auth"
  #   external_groups = ["app-consul-user"]
  # }
]
