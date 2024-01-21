eci_image_uri      = "docker.io/gitlab/gitlab-ee:16.5.1-ee.0"
eci_restart_policy = "Never"
# https://github.com/laradock/laradock/blob/b75d8ba0bd6527ff2a5ad879f111fa592e677c59/docker-compose.yml#L1498C39-L1498C39
GITLAB_OMNIBUS_CONFIG = <<-EOT
external_url 'https://gitlab.devops.p2w3'
nginx['listen_https'] = false
nginx['listen_port'] = 80

redis['enable'] = false
gitlab_rails['redis_host'] = 'redis'

postgresql['enable'] = false
gitlab_rails['redis_database'] = 8
gitlab_rails['db_host'] = '${GITLAB_POSTGRES_HOST}'
gitlab_rails['db_username'] = '${GITLAB_POSTGRES_USER}'
gitlab_rails['db_password'] = '${GITLAB_POSTGRES_PASSWORD}'
gitlab_rails['db_database'] = '${GITLAB_POSTGRES_DB}'
gitlab_rails['initial_root_password'] = '${GITLAB_ROOT_PASSWORD}'

gitlab_rails['gitlab_shell_ssh_port'] = 22
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true
gitlab_rails['omniauth_providers'] = [
  {
    name: 'saml', 
    label: 'AliCloud IDaaS',
    args: {
      name: 'saml', 
      assertion_consumer_service_url: 'https://gitlab.{{ external_basedomain }}/users/auth/saml/callback',
      idp_cert_fingerprint: '80:47:29:40:BD:9D:B2:C5:5F:A9:75:66:84:FB:41:5B:D4:35:36:E8',
      idp_sso_target_url: 'https://xxxxxx.cloud-idaas.com/login/app/app_msxgnhonbnuqhcij6gnezx5cca/saml2/sso',
      issuer: 'https://gitlab.{{ external_basedomain }}/users/auth/saml',
      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
      attribute_statements: { 
        nickname: ['username'],
      },
    },
  }
]
EOT
