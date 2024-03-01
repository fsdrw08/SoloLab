#!/bin/bash

# https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
export $(grep -v '^#' ${ENV_FILE} | xargs)

function authenticate {
    # Authenticate Vault
    printf "Authenticating Vault...\n"
    VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
    VAULT_TOKEN=$(echo $VAULT_OPERATOR_SECRETS | jq -r .root_token)
    export VAULT_TOKEN=$VAULT_TOKEN
}

# https://github.com/Kehrlann/concourse-demo/blob/ecf3b68b5da125b6c14f5e04642dc0aa835250e2/demo/infrastructure/setup-vault.sh#L36-L40
function create_token {
    if ! vault token lookup ${STATIC_TOKEN} > /dev/null 2>&1; then
        vault token create -policy=root -id=${STATIC_TOKEN}
    else
        echo '√ vault: static token already enabled'
    fi
}

function unauthenticate {
    # Unauthenticate Vault
    printf "Unauthenticating Vault...\n"
    unset VAULT_TOKEN
    printf "Unauthenticated Vault.\n"
}


authenticate
create_token
unauthenticate