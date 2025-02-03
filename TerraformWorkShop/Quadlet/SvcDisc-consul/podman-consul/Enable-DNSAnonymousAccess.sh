#!/bin/bash
# https://developer.hashicorp.com/consul/docs/services/discovery/dns-static-lookups#acls
sleep 2s

# 设置Consul服务端地址和初始化token
CONSUL_HTTP_ADDR=${CONSUL_HTTP_ADDR}
INIT_TOKEN=${INIT_TOKEN}

# 检查是否存在名为anonymous的policy
POLICY_NAME="anonymous"
POLICY_ID=$(curl -s -k -H "X-Consul-Token: $INIT_TOKEN" "$CONSUL_HTTP_ADDR/v1/acl/policies" | jq -r '.[] | select(.Name == "'$POLICY_NAME'") | .ID')

if [ -z "$POLICY_ID" ]; then
  echo "Policy '$POLICY_NAME' does not exist. Creating it now..."

  # 定义policy规则（HCL格式）
  POLICY_RULES='node_prefix \"\" { policy = \"read\" } service_prefix \"\" { policy = \"read\" }'

  # 创建policy
  CREATE_POLICY_RESPONSE=$(curl -s -k -X PUT -H "X-Consul-Token: $INIT_TOKEN" -d '{
    "Name": "'$POLICY_NAME'",
    "Rules": "'"$POLICY_RULES"'"
}' "$CONSUL_HTTP_ADDR/v1/acl/policy")

  POLICY_ID=$(echo "$CREATE_POLICY_RESPONSE" | jq -r '.ID')

  if [ -z "$POLICY_ID" ]; then
    echo "Failed to create policy '$POLICY_NAME'."
    echo "Response: $CREATE_POLICY_RESPONSE"
    exit 1
  else
    echo "Policy '$POLICY_NAME' created with ID: $POLICY_ID"
  fi
else
  echo "Policy '$POLICY_NAME' already exists with ID: $POLICY_ID"
fi

# 给指定的ACL token分配policy
TOKEN_ID="00000000-0000-0000-0000-000000000002"
UPDATE_TOKEN_RESPONSE=$(curl -s -k -X PUT -H "X-Consul-Token: $INIT_TOKEN" -d '{
  "Policies": [
    {
      "ID": "'$POLICY_ID'"
    }
  ]
}' "$CONSUL_HTTP_ADDR/v1/acl/token/$TOKEN_ID")

UPDATED_TOKEN_ID=$(echo "$UPDATE_TOKEN_RESPONSE" | jq -r '.ID')

if [ -z "$UPDATED_TOKEN_ID" ]; then
  echo "Failed to update token '$TOKEN_ID' with policy '$POLICY_NAME'."
  echo "Response: $UPDATE_TOKEN_RESPONSE"
  exit 1
else
  echo "Token '$TOKEN_ID' updated with policy '$POLICY_NAME'."
fi