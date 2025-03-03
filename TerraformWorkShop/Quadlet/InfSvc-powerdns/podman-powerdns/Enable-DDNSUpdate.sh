#!/bin/bash

# 设置变量
PDNS_HOST=${PDNS_HOST}  # PowerDNS API 地址
API_KEY=${PDNS_API_KEY}  # PowerDNS API 密钥
ZONE_NAME=${ZONE_NAME}  # 要操作的域名
ZONE_FQDN=${ZONE_FQDN}  # 要操作的域名
TSIG_KEY_ID=${TSIG_KEY_NAME}  # TSIG key 的名称
TSIG_KEY_CONTENT=${TSIG_KEY_CONTENT}  # TSIG key 的内容

# 检查 zone 是否存在
check_zone_exist() {
    curl -s -o /dev/null -w "%%{http_code}" -H "X-API-Key: $API_KEY" "$PDNS_HOST/api/v1/servers/localhost/zones/$ZONE_NAME"
}

# 创建 zone
create_zone() {
    curl -X POST -H "X-API-Key: $API_KEY" -H "Content-Type: application/json" -d '{
        "name": "'"$ZONE_NAME"'",
        "kind": "Native",
        "nameservers": ["ns1.day0.sololab."]
    }' "$PDNS_HOST/api/v1/servers/localhost/zones"
}

# 检查 TSIG key 是否存在
check_tsig_key_exist() {
    curl -s -o /dev/null -w "%%{http_code}" -H "X-API-Key: $API_KEY" "$PDNS_HOST/api/v1/servers/localhost/tsigkeys/$TSIG_KEY_ID"
}

# 创建 TSIG key
create_tsig_key() {
    curl -X POST -H "X-API-Key: $API_KEY" -H "Content-Type: application/json" -d '{
        "name": "'"$TSIG_KEY_ID"'",
        "algorithm": "hmac-sha256",
        "key": "'"$TSIG_KEY_CONTENT"'",
        "type": "TSIGKey"
    }' "$PDNS_HOST/api/v1/servers/localhost/tsigkeys"
}

# 更新 TSIG key
update_tsig_key() {
    curl -s -o /dev/null -X PUT -H "X-API-Key: $API_KEY" -H "Content-Type: application/json" -d '{
        "name": "'"$TSIG_KEY_ID"'",
        "algorithm": "hmac-sha256",
        "key": "'"$TSIG_KEY_CONTENT"'",
        "type": "TSIGKey"
    }' "$PDNS_HOST/api/v1/servers/localhost/tsigkeys/$TSIG_KEY_ID"
}

### Metadata 操作函数
check_metadata_exists() {
    local metadata_name="$1"
    response=$(curl -sS -H "X-API-Key: $API_KEY" \
        "$PDNS_HOST/api/v1/servers/localhost/zones/$ZONE_NAME/metadata")
    
    if echo "$response" | jq -e ".[] | select(.kind == \"$metadata_name\")" > /dev/null; then
        echo "exists"
    else
        echo "not_exists"
    fi
}

# 创建 metadata
create_metadata() {
    local name="$1"
    local value="$2"
    curl -X POST -sS -H "X-API-Key: $API_KEY" -H "Content-Type: application/json" \
        -d '{
            "kind": "'"$name"'",
            "metadata": ["'"$value"'"]
        }' \
        "$PDNS_HOST/api/v1/servers/localhost/zones/$ZONE_NAME/metadata"
}

# 主逻辑
if [ "$(check_zone_exist)" != "200" ]; then
    echo "Zone $ZONE_NAME does not exist, creating..."
    create_zone
else
    echo "Zone $ZONE_NAME already exists."
fi

if [ "$(check_tsig_key_exist)" != "200" ]; then
    echo "TSIG key $TSIG_KEY_ID does not exist, creating..."
    create_tsig_key
else
    echo "TSIG key $TSIG_KEY_ID already exists, updating..."
    update_tsig_key
    echo "update done"
fi

if [ "$(check_metadata_exists 'ALLOW-DNSUPDATE-FROM')" = "not_exists" ]; then
    echo "Metadata ALLOW-DNSUPDATE-FROM does not exist, creating..."
    create_metadata "ALLOW-DNSUPDATE-FROM" "0.0.0.0/0"
else
    echo "Metadata ALLOW-DNSUPDATE-FROM already exists."
fi

if [ "$(check_metadata_exists 'TSIG-ALLOW-DNSUPDATE')" = "not_exists" ]; then
    echo "Metadata TSIG-ALLOW-DNSUPDATE does not exist, creating..."
    create_metadata "TSIG-ALLOW-DNSUPDATE" "$TSIG_KEY_ID"
else
    echo "Metadata TSIG-ALLOW-DNSUPDATE already exists."
fi

echo "Script execution completed."