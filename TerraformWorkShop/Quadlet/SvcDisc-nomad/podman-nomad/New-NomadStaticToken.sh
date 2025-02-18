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

# 检测路径是否存在以及文件内容是否为空
if [ ! -f "$BOOTSTRAP_TOKEN_FILE" ] || [ ! -s "$BOOTSTRAP_TOKEN_FILE" ]; then
    # 发送HTTP请求到 $NOMAD_ADDR/v1/acl/bootstrap
    response=$(curl -s -k -X POST "$NOMAD_ADDR/v1/acl/bootstrap" | jq -r .SecretID)
    
    # 检查响应是否成功
    if [ $? -eq 0 ]; then
        # 将响应内容输出到 $BOOTSTRAP_TOKEN_FILE 文件中
        echo "export NOMAD_TOKEN=\"$response\"" > "$BOOTSTRAP_TOKEN_FILE"
        echo "ACL tokens information has been written to $BOOTSTRAP_TOKEN_FILE"
    else
        echo "Failed to fetch ACL tokens from $NOMAD_ADDR/v1/acl/bootstrap"
    fi
else
    echo "The file $BOOTSTRAP_TOKEN_FILE exists and contains data."
fi