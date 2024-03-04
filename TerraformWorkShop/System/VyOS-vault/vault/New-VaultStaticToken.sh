#!/bin/bash

# https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
export $(grep -v '^#' ${ENV_FILE} | xargs)

# https://github.com/Indellient/vault-habitat/blob/2a010ee30b2639e65d3df5ad05df47c07c0eec55/vault/hooks/run#L49
function wait_started {
    counter=0
    until STATUS=$(vault status -format=json); [ $? -ne 1 ]
    do
        if [ $counter -lt 5 ]; then
            echo "Waiting for vault to come up"
            sleep 5
            ((counter++))
        else
            echo "check vault status manually"
            exit 1
        fi
    done
    echo "Vault is started"
}

function wait_ready {
    retried=1
    # https://github.com/homedepot/spingo/blob/d5f418cc438ec176a219258f816178028cec5394/scripts/initial-setup.sh#L305
    status=$(vault status -format json | jq -r '. | select(.initialized == true and .sealed == false) | .initialized')
    until [ "$status" = "true" ]
    do
        if [ $retried -lt 3 ]; then
            echo "[$retried] Vault not initialized nor unseal "
            ((retried++))
            sleep 5
            status=$(vault status -format json | jq -r '. | select(.initialized == true and .sealed == false) | .initialized')
        else
            echo "check vault stauts manually"
            exit 1
        fi
    done
    echo "Vault is initialized and unsealed"
}

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

wait_started
wait_ready
authenticate
create_token
unauthenticate