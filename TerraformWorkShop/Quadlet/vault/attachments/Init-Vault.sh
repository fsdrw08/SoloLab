#!/bin/sh

function wait_started {
    counter=0
    until STATUS=$(vault status -format=json 2>&1); [ $? -ne 1 ]
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

function is_inited {
  # https://unix.stackexchange.com/questions/109835/how-do-i-use-cut-to-separate-by-multiple-whitespace/109894#109894
  vault status | grep Initialized | awk '{print $NF}'
}

function init {
    # Initialize Vault
    printf "Initializing Vault...\n"
    vault operator init > $VAULT_OPERATOR_SECRETS_PATH
    printf "Vault initialized.\n"
}

function is_sealed {
    vault status | grep Sealed | awk '{print $NF}'
}

function unseal {
    # Unseal Vault
    printf "Unsealing Vault...\n"
    # VAULT_UNSEAL_KEYS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH | jq -r .unseal_keys_b64[])
    VAULT_UNSEAL_KEYS=$(cat $VAULT_OPERATOR_SECRETS_PATH | grep Unseal | cut -d " " -f4 | head -n 3)
    for VAULT_UNSEAL_KEY in $VAULT_UNSEAL_KEYS; do
        vault operator unseal $VAULT_UNSEAL_KEY > /dev/null
    done
}

function authenticate {
    # Authenticate Vault
    printf "Authenticating Vault...\n"
    # VAULT_TOKEN=$(cat $VAULT_OPERATOR_SECRETS_PATH | jq -r .root_token)
    VAULT_TOKEN=$(grep 'Initial Root Token' $VAULT_OPERATOR_SECRETS_PATH | cut -d ':' -f2 | tr -d ' ')
    export VAULT_TOKEN=$VAULT_TOKEN
}

function unauthenticated {
    # Unauthenticated Vault
    printf "Unauthenticating Vault...\n"
    unset VAULT_TOKEN
    printf "Unauthenticated Vault.\n"
}

# Helper functions

function vault_status {
    printf "Vault status:\n"
    vault status
}

if [[ $(is_inited) == "false" ]]; then
    # Vault is not initialized
    printf "Vault is not initialized.\nStarting the initialization..\n"
    wait_started
    init
    unseal
fi

if [[ $(is_inited) == "true" && $(is_sealed) == "false" ]]; then
    # Vault is already initialized
    printf "Vault is already initialized.\n"
    wait_started
    unseal
fi

vault_status