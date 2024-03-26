#!/bin/bash
# https://github.com/CENSUS/vault-secrets-abe-janus/blob/efcf03fe682911b1bc6d3d328c5d5af37fcf889c/other/docker/vault/config/vault_init.sh

# export VAULT_ADDR="$VAULT_ADDR"
# export VAULT_CACERT="$VAULT_CACERT"

# VAULT_OPERATOR_SECRETS_JSON_PATH="$VAULT_OPERATOR_SECRETS_JSON_PATH"

# MAIN FUNCTIONS

# https://github.com/Indellient/vault-habitat/blob/2a010ee30b2639e65d3df5ad05df47c07c0eec55/vault/hooks/run#L49
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

function init {
    # Initialize Vault
    printf "Initializing Vault...\n"
    VAULT_OPERATOR_SECRETS=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
    # Export Vault operator keys (root_token and unseal keys)
    echo $VAULT_OPERATOR_SECRETS | jq . >$VAULT_OPERATOR_SECRETS_JSON_PATH
    printf "Vault initialized.\n"
}

function unseal {
    # Unseal Vault
    printf "Unsealing Vault...\n"
    VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
    VAULT_UNSEAL_KEYS=$(echo $VAULT_OPERATOR_SECRETS | jq -r .unseal_keys_b64[])
    for VAULT_UNSEAL_KEY in $VAULT_UNSEAL_KEYS; do
        vault operator unseal $VAULT_UNSEAL_KEY
    done
}

function authenticate {
    # Authenticate Vault
    printf "Authenticating Vault...\n"
    VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
    VAULT_TOKEN=$(echo $VAULT_OPERATOR_SECRETS | jq -r .root_token)
    export VAULT_TOKEN=$VAULT_TOKEN
}

function unauthenticate {
    # Unauthenticate Vault
    printf "Unauthenticating Vault...\n"
    unset VAULT_TOKEN
    printf "Unauthenticated Vault.\n"
}

# Helper functions

function vault_status {
    printf "Vault status:\n"
    vault status
}

function vault_health {
    printf "Vault health:\n"
    vault status -format=json
}

if [[ -f "$VAULT_OPERATOR_SECRETS_JSON_PATH" && $(stat -c%s "$VAULT_OPERATOR_SECRETS_JSON_PATH") -gt 1 ]]; then
# if [ -f $VAULT_OPERATOR_SECRETS_JSON_PATH ]; then
    # Vault is already initialized
    printf "Vault is already initialized.\n"
    wait_started
    unseal
    authenticate
    vault_status
    vault_health
    unauthenticate
else
    # Vault is not initialized
    printf "Vault is not initialized.\nStarting the initialization..\n"
    wait_started
    init
    unseal
    authenticate
    vault_status
    vault_health
    unauthenticate
fi