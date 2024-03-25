#!/bin/bash

export CONSUL_CACERT="${CONSUL_CACERT}"

export POLICY_NAME="tfstate"

export TOKEN_DESC="terraform"

# create consul acl policy for the token which use in terraform
# https://github.com/oracle-devrel/consul-testing-validation/blob/c94283e4b1846fa7424fe1e85f9395f63fa3de75/terraform_cts/scripts/cts_install.sh#L63-L72
if [[ ! $(consul acl policy list -http-addr=http://${client_addr} -token=${token_init_mgmt} -format json | jq '.[] | .Name') =~ $POLICY_NAME ]]; 
then
consul acl policy create -http-addr=http://${client_addr} -token=${token_init_mgmt} -name $POLICY_NAME -rules - <<'EOF'
key_prefix "tfstate/" {
  policy = "write"
}
session_prefix "" {
  policy = "write"
}
EOF
fi;

# create consul acl token with above policy
if [[ ! $(consul acl token list -http-addr=http://${client_addr} -token=${token_init_mgmt} -format json | jq '.[] | .Description') =~ $TOKEN_DESC ]]; 
then
consul acl token create -http-addr=http://${client_addr} -token=${token_init_mgmt} -description $TOKEN_DESC \
    -policy-name $POLICY_NAME \
    -secret ${secret_id}
fi;
