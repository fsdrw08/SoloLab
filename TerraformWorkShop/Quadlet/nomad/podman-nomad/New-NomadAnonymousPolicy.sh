#!/bin/sh

NOMAD_ADDR=${NOMAD_ADDR}
NOMAD_TOKEN_FILE=${NOMAD_TOKEN_FILE}

counter=0
# until STATUS=$(curl -k -X GET "$NOMAD_ADDR/v1/status/leader" 2>&1); [ $? -ne 1 ]
until curl -fLsSk -X GET "$NOMAD_ADDR/v1/status/leader" > /dev/null
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

# 检测路径是否存在以及文件内容是否为空
if [ ! -f "$NOMAD_TOKEN_FILE" ] || [ ! -s "$NOMAD_TOKEN_FILE" ]; then
    # 发送HTTP请求到 $NOMAD_ADDR/v1/acl/bootstrap
    NOMAD_TOKEN=$(curl -s -k -X POST "$NOMAD_ADDR/v1/acl/bootstrap" | jq -r .SecretID) 
    echo "token: $NOMAD_TOKEN"
    # 检查响应是否成功
    if [ $? -eq 0 ]; then
        # 将响应内容输出到 $NOMAD_TOKEN_FILE 文件中
        ls -al $(dirname $NOMAD_TOKEN_FILE)
        echo "$NOMAD_TOKEN" > $NOMAD_TOKEN_FILE
        echo "ACL tokens information has been written to $NOMAD_TOKEN_FILE"
    else
        echo "Failed to fetch ACL tokens from $NOMAD_ADDR/v1/acl/bootstrap"
    fi
else
    echo "The file $NOMAD_TOKEN_FILE exists and contains data."
fi

NOMAD_TOKEN=$(cat $NOMAD_TOKEN_FILE)
echo $NOMAD_TOKEN
# 查询现有的ACL策略
POLICIES=$(curl -s -k -H "X-Nomad-Token: $NOMAD_TOKEN" "$NOMAD_ADDR/v1/acl/policies")

# 检查是否存在名为anonymous的策略
if echo "$POLICIES" | jq -e '.[] | select(.Name == "anonymous")' > /dev/null; then
  echo "Policy 'anonymous' already exists."
else
  echo "Policy 'anonymous' does not exist. Creating it now..."

  # 定义新的ACL策略
  POLICY_JSON='{
    "Name": "anonymous",
    "Description": "Read-only access to nodes, agents, and quotas",
    "Rules": "namespace \"default\" { policy = \"read\" } node { policy = \"read\" } agent { policy = \"read\" } quota { policy = \"read\" }"
  }'

  # 创建新的ACL策略
  curl -k -X POST -H "X-Nomad-Token: $NOMAD_TOKEN" -H "Content-Type: application/json" \
       --data "$POLICY_JSON" "$NOMAD_ADDR/v1/acl/policy/anonymous"

  echo "Policy 'anonymous' created successfully."
fi