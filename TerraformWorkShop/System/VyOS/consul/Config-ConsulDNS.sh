#!/bin/bash
/usr/bin/sleep 5

if [[ ! $(consul acl policy list -http-addr=http://${client_addr} -token=${token_init_mgmt} -format json | jq '.[] | .Name') =~ 'anonymous' ]]; 
then
consul acl policy create -http-addr=http://${client_addr} -token=${token_init_mgmt} -name anonymous -rules - <<'EOF'
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
EOF
fi;

consul acl token update -http-addr=http://${client_addr} -token=${token_init_mgmt} -id 00000000-0000-0000-0000-000000000002 -policy-name anonymous -description 'Anonymous Token'