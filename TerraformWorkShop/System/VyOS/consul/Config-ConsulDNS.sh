#!/bin/bash
/usr/bin/sleep 5

if [[ ! $(consul acl policy list -http-addr=http://${var.consul.config.vars.client_addr}:8500 -token=${var.consul.config.vars.token_init_mgmt} -format json | jq '.[] | .Name') =~ 'anonymous' ]]; 
then
consul acl policy create -http-addr=http://${var.consul.config.vars.client_addr}:8500 -token=${var.consul.config.vars.token_init_mgmt} -name anonymous -rules - <<'EOF'
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
EOF
fi;