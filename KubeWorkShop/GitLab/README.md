- ref:
https://docs.gitlab.com/ee/install/docker.html
https://hub.docker.com/r/gitlab/gitlab-ce

- gitlab docker image is too big, consider pull it manually first
```shell
version="docker.io/gitlab/gitlab-ce:15.11.11-ce.0"
podman pull $version
```

### SSO with SAML
For SSO with SAML (alicloud IDaaS), add below config  
ref:
- https://docs.gitlab.com/ee/integration/saml.html
- https://docs.gitlab.com/ee/user/group/saml_sso/index.html#manage-user-saml-identity
- https://help.aliyun.com/document_detail/420709.html
```rb
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true
gitlab_rails['omniauth_providers'] = [
  {
    name: 'saml', 
    label: 'EIAM2.0',
    args: {
      name: 'saml', 
      assertion_consumer_service_url: 'https://gitlab.devops.p2w3/users/auth/saml/callback',
      idp_cert_fingerprint: '80:47:29:40:BD:9D:B2:C5:5F:A9:75:66:84:FB:41:5B:D4:35:36:E8',
      idp_sso_target_url: 'https://xxxxx.cloud-idaas.com/login/app/xxx/saml2/sso',
      issuer: 'https://gitlab.devops.p2w3/users/auth/saml',
      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
      attribute_statements: { 
        nickname: ['username'],
        email: ['email'],
      },
    },
  }
]
```

### Setup Sign-in restrictions  
ref:
- https://docs.gitlab.com/15.11/ee/user/admin_area/settings/sign_in_restrictions.html

note:  
  - Sign-in restrictions will also block root's username/password login, to prevent lost root access, need to assign at least one user as admin first

procedure:
  1. setup external idp when deploy gitlab, e.g. saml or OIDC
  2. login with external idp user, to let the user info saved in gitlab
  3. login with root, assign that external auth user as administrator, then go to /admin/application_settings/general, uncheck "Allow password authentication for the web interface", and check "Admin Mode"