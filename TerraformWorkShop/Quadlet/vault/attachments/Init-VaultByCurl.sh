#!/bin/sh

VAULT_ADDR=${VAULT_ADDR}
VAULT_OPERATOR_SECRETS_JSON_PATH=${VAULT_OPERATOR_SECRETS_JSON_PATH}


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

function is_inited {
  curl -s -k --request GET "$VAULT_ADDR/v1/sys/health" | jq -r .initialized
}

function init {
  # Initialize Vault
  printf "Initializing Vault...\n"
  VAULT_OPERATOR_SECRETS=$(curl -s -k -X POST \
    -H "Content-Type: application/json" \
    -d '{ "secret_shares": 1, "secret_threshold": 1 }' \
    "$VAULT_ADDR/v1/sys/init")
  # Export Vault operator keys (root_token and unseal keys)
  echo $VAULT_OPERATOR_SECRETS | jq . >$VAULT_OPERATOR_SECRETS_JSON_PATH
  printf "Vault initialized.\n"
}

function is_sealed {
  curl -s -k --request GET "$VAULT_ADDR/v1/sys/health" | jq -r .sealed
}

function unseal {
  # Unseal Vault
  printf "Unsealing Vault...\n"
  VAULT_OPERATOR_SECRETS=$(cat $VAULT_OPERATOR_SECRETS_JSON_PATH)
  VAULT_UNSEAL_KEYS=$(echo $VAULT_OPERATOR_SECRETS | jq -r .keys[])
  for VAULT_UNSEAL_KEY in $VAULT_UNSEAL_KEYS; do
      # https://developer.hashicorp.com/vault/api-docs/system/unseal
      curl -s -k --request POST \
        --data "{ \"key\": \"$VAULT_UNSEAL_KEY\" }" \
        "$VAULT_ADDR/v1/sys/unseal"
  done
}

wait_started

sleep 5s 
echo "is_inited ?"
is_inited

# init
if [[ $(is_inited) != "true" ]]; then
  init
else
  printf "Vault is already initialized.\n"
fi

sleep 5s 

echo "is_inited"
is_inited
echo "is_sealed"
is_sealed

# unseal
if [[ $(is_inited) == "true" && $(is_sealed) == "true" ]]; then
  if [[ -f "$VAULT_OPERATOR_SECRETS_JSON_PATH" && $(stat -c%s "$VAULT_OPERATOR_SECRETS_JSON_PATH") -gt 1 ]]; then
    unseal
    exit 0
  else
    echo "no keys in file, please check"
    exit 1
  fi
fi