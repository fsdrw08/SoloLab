# https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/18.11.1+ee.0/docker/assets/gitlab.rb
# https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/18.11.1+ee.0/files/gitlab-config-template/gitlab.rb.template
# https://github.com/matiaet98/hashicluster/blob/7240ee9ca68d28e020e5af0d696c8b0e37b05835/jobs/gitlab/gitlab.nomad
external_url 'https://gitlab.{{ env "attr.unique.hostname" }}.sololab'

# https://docs.gitlab.com/administration/object_storage/?tab=Linux+package+%28Omnibus%29#full-example-using-the-consolidated-form-and-amazon-s3
gitlab_rails['object_store']['enabled'] = false
gitlab_rails['object_store']['connection'] = {
    'provider' => 'AWS',
    'region' => 'us-east-1',
	'aws_access_key_id' => '{{with secret "kvv2_minio/data/gitlab"}}{{.Data.data.access_key}}{{end}}',
	'aws_secret_access_key' => '{{with secret "kvv2_minio/data/gitlab"}}{{.Data.data.secret_key}}{{end}}',
	'endpoint' => 'https://minio.day1.sololab',
	'path_style' => true
}
gitlab_rails['object_store']['objects']['artifacts']['bucket'] = "gitlab-artifacts"
gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = "gitlab-external-diffs"
gitlab_rails['object_store']['objects']['lfs']['bucket'] = "gitlab-lfs"
gitlab_rails['object_store']['objects']['uploads']['bucket'] = "gitlab-uploads"
gitlab_rails['object_store']['objects']['packages']['bucket'] = "gitlab-packages"
gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = "gitlab-dependency-proxy"
gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = "gitlab-terraform-state"
gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = "gitlab-ci-secure-files"
gitlab_rails['object_store']['objects']['pages']['bucket'] = "gitlab-pages"
gitlab_rails['object_store']['proxy_download'] = false

postgresql['enable'] = false
gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "unicode"
gitlab_rails['db_host'] = "pgbouncer.service.consul"
gitlab_rails['db_port'] = 6432
gitlab_rails['db_database'] = "gitlabhq_production"
gitlab_rails['db_username'] = '{{with secret "kvv2_others/data/app-gitlab"}}{{.Data.data.pgsql_user_name}}{{end}}'
gitlab_rails['db_password'] = '{{with secret "kvv2_others/data/app-gitlab"}}{{.Data.data.pgsql_user_password}}{{end}}'
gitlab_rails['db_sslmode'] = "require"
gitlab_rails['db_sslrootcert'] = "/etc/gitlab/trusted-certs/sololab.ca.crt"

## Registry database
##! Docs: https://docs.gitlab.com/ee/administration/packages/container_registry_metadata_database.html#new-installations
registry['auto_migrate'] = false
registry['database'] = {
  'enabled' => "false",
  'host' => "pgbouncer.service.consul",
  'port' => 6432,
  'user' => '{{with secret "kvv2_others/data/app-gitlab"}}{{.Data.data.pgsql_user_name}}{{end}}',
  'password' => '{{with secret "kvv2_others/data/app-gitlab"}}{{.Data.data.pgsql_user_password}}{{end}}',
  'dbname' => 'gitlabhq_registry',
  'sslmode' => 'require',
  'sslrootcert' => '/etc/gitlab/trusted-certs/sololab.ca.crt',
}


redis['enable'] = false
gitlab_rails['redis_host'] = 'redis-day3.service.consul'
gitlab_rails['redis_port'] = 6379
# gitlab_rails['redis_password'] = 'gitea'
gitlab_rails['redis_password'] = 'gitlab'

nginx['enable'] = false
prometheus['enable'] = false