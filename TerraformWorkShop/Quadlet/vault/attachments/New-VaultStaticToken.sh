#!/bin/bash

# https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
VAULT_OPERATOR_SECRETS_JSON_PATH=${VAULT_OPERATOR_SECRETS_JSON_PATH}
VAULT_ADDR=${VAULT_ADDR}
STATIC_TOKEN=${STATIC_TOKEN}

# https://github.com/Indellient/vault-habitat/blob/2a010ee30b2639e65d3df5ad05df47c07c0eec55/vault/hooks/run#L49
function wait_started {
  counter=0
  until STATUS=$(curl -k -X GET "$VAULT_ADDR/v1/sys/health" 2>&1); [ $? -ne 1 ]
  do
    if [ $counter -lt 20 ]; then
      echo "Waiting for vault to come up, $(($counter*5))s passed"
      sleep 5
      ((counter++))
    else
      echo "check vault stauts manually"
      exit 1
    fi
  done
  echo "Vault is started"
}

function wait_ready {
    retried=1
    # https://github.com/homedepot/spingo/blob/d5f418cc438ec176a219258f816178028cec5394/scripts/initial-setup.sh#L305
    status=$(curl -s -k -X GET "$VAULT_ADDR/v1/sys/health" | jq -r '. | select(.initialized == true and .sealed == false) | .initialized')
    until [ "$status" = "true" ]
    do
        if [ $retried -lt 10 ]; then
            echo "[$retried] Vault not initialized nor unseal "
            ((retried++))
            sleep 5
            status=$(curl -s -k -X GET "$VAULT_ADDR/v1/sys/health" | jq -r '. | select(.initialized == true and .sealed == false) | .initialized')
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
    # VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
    # VAULT_TOKEN=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH | grep "Initial Root Token" | awk '{print $NF}')
    # INIT_VAULT_TOKEN=$(jq .root_token $VAULT_OPERATOR_SECRETS_JSON_PATH)
    # https://github.com/hashicorp/vault/issues/6287#issuecomment-684125899
    INIT_VAULT_TOKEN=$(echo $(base64 -d $VAULT_OPERATOR_SECRETS_JSON_PATH | jq .root_token )| tr -d '"')
    export INIT_VAULT_TOKEN=$INIT_VAULT_TOKEN
}

# https://github.com/Kehrlann/concourse-demo/blob/ecf3b68b5da125b6c14f5e04642dc0aa835250e2/demo/infrastructure/setup-vault.sh#L36-L40
function create_token {
    RESULT=$(curl -s -k --request POST \
        -H "X-Vault-Token: $INIT_VAULT_TOKEN" \
        --data "{ \"token\": \"$STATIC_TOKEN\" }" \
        $VAULT_ADDR/v1/auth/token/lookup | jq -r .data.id)

    if [ $RESULT != $STATIC_TOKEN ]; then
        echo "New static token"
        curl -s -k --request POST \
            --header "X-Vault-Token: $INIT_VAULT_TOKEN" \
            --data "{  \"policies\": [\"root\"],  \"id\": \"$STATIC_TOKEN\" }" \
            $VAULT_ADDR/v1/auth/token/create
    else
        echo $RESULT
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