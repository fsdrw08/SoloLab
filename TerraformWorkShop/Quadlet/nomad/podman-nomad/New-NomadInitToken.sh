#!/bin/sh

NOMAD_ADDR=${NOMAD_ADDR}
BOOTSTRAP_TOKEN_FILE=${BOOTSTRAP_TOKEN_FILE}

counter=0
until STATUS=$(curl -k -X GET "$NOMAD_ADDR/v1/status/leader" 2>&1); [ $? -ne 1 ]
do
  if [ $counter -lt 20 ]; then
    echo "Waiting for nomad to come up, $(($counter*5))s passed"
    sleep 5
    ((counter++))
  else
    echo "check nomad stauts manually"
    exit 1
  fi
done
echo "nomad is started"

response=$(curl -s -k -X POST "$NOMAD_ADDR/v1/acl/bootstrap")
if echo "$response" | jq . > /dev/null 2>&1; then
  echo "ACL bootstrap successful"
else
  NOMAD_TOKEN=$($response | jq -r .SecretID) podman secret create --env=true --replace=true nomad-sec-token NOMAD_TOKEN
  systemctl --user restart nomad-container.service
fi