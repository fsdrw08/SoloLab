#!/bin/bash

# 幂等的创建 etcd root 用户并赋予 root 权限的脚本
set -euo pipefail

# 配置参数
ETCD_ENDPOINT="${ETCD_ENDPOINT}"
ROOT_USERNAME="${ROOT_USERNAME}"
ROOT_PASSWORD="${ROOT_PASSWORD}"
AUTH_ENABLED_FLAG_FILE="/tmp/etcd_auth_enabled.flag"

# 函数：检查 etcd 是否可用
check_etcd_health() {
    echo "检查 etcd 服务状态..."
    if curl -k -s -f "${ETCD_ENDPOINT}/health" | grep -q '"health":"true"'; then
        echo "✓ etcd 服务正常"
        return 0
    else
        echo "✗ etcd 服务不可用或健康检查失败"
        return 1
    fi
}

# 函数：检查认证是否已启用
is_auth_enabled() {
    local response
    response=$(curl -k -s "${ETCD_ENDPOINT}/v3/auth/status" -X POST 2>/dev/null || true)
    
    if echo "$${response}" | grep -q 'user name is empty'; then
        echo "✓ 认证已启用"
        return 0
    elif echo "$${response}" | grep -q '"authRevision"'; then
        echo "✓ 认证未启用"
        return 1
    else
        echo "⚠ 无法获取认证状态，可能是不支持的版本或服务异常"
        return 2
    fi
}

# 函数：检查用户是否存在
user_exists() {
    local username=$1
    local response
    response=$(curl -k -s "${ETCD_ENDPOINT}/v3/auth/user/get" -X POST \
        -d "{\"name\": \"$${username}\"}" 2>/dev/null || true)
    
    if echo "$${response}" | grep -q "user name not found"; then
        return 1
    else
        return 0
    fi
}

# 函数：启用认证
enable_auth() {
    echo "启用 etcd 认证..."
    if curl -k -s -f "${ETCD_ENDPOINT}/v3/auth/enable" -X POST; then
        echo "✓ 认证启用成功"
        touch "$${AUTH_ENABLED_FLAG_FILE}"
        return 0
    else
        echo "✗ 认证启用失败"
        return 1
    fi
}

# 函数：创建用户
create_user() {
    local username=$1
    local password=$2
    echo "创建用户: $${username}"
    
    if curl -k -s -f "${ETCD_ENDPOINT}/v3/auth/user/add" -X POST \
        -d "{\"name\": \"$${username}\", \"password\": \"$${password}\"}"; then
        echo "✓ $${username} 用户创建成功"
        return 0
    else
        echo "✗ $${username} 用户创建失败"
        return 1
    fi
}

# 创建角色
create_role() {
    local rolename=$1

    if curl -k -s -f "${ETCD_ENDPOINT}/v3/auth/role/add" -X POST \
        -d "{\"name\": \"$${rolename}\"}"; then
        echo "✓ $${rolename} 角色创建成功"
        return 0
    else
        echo "✗ $${rolename} 角色创建失败"
        return 1
    fi
}

# 配置角色权限
grant_role_permission(){
    local rolename=$1
    local key_b64=$(echo -n $2 | base64)
    local range_b64=$3
    local permission=$4

    echo $key_b64
    echo $range_b64

    if curl -k -f "${ETCD_ENDPOINT}/v3/auth/role/grant" -X POST \
        -d "{\"name\": \"$${rolename}\",\"perm\":{\"key\":\"$${key_b64}\",\"range_end\":\"$${range_b64}\",\"permType\":\"$${permission}\"}}"; then
        echo "✓ $${rolename} 角色赋权成功"
        return 0
    else
        echo "✗ $${rolename} 角色赋权失败"
        return 1
    fi
}

# 函数：指定用户角色
grant_user_role() {
    local username=$1
    local rolename=$2

    echo "为用户 $${username} 授予 $${rolename} 角色..."
    
    if curl -k -s -f "${ETCD_ENDPOINT}/v3/auth/user/grant" -X POST \
        -d "{\"user\": \"$${username}\", \"role\": \"$${rolename}\"}"; then
        echo "✓ $${rolename} 角色分配成功"
        return 0
    else
        echo "✗ $${rolename} 角色分配失败"
        return 1
    fi
}

# 函数：验证认证配置
verify_auth_config() {
    echo "验证认证配置..."
    
    # 使用 root 用户执行一个需要权限的操作来验证
    local token
    token=$(curl -k -s -L ${ETCD_ENDPOINT}/v3/auth/authenticate \
        -X POST \
        -d "{\"name\": \"${ROOT_USERNAME}\", \"password\": \"${ROOT_PASSWORD}\"}" | jq .token | tr -d '"')

    local auth_header
    auth_header="Authorization: $token"
    
    if curl -k -f "${ETCD_ENDPOINT}/v3/auth/user/list" -X POST \
        -H "$${auth_header}" | grep -q "\"users\":"; then
        echo "✓ 认证配置验证成功"
        return 0
    else
        echo "✗ 认证配置验证失败"
        return 1
    fi
}

# 主执行逻辑
main() {
    echo "开始配置 etcd 认证和 root 用户..."
    echo "ETCD 端点: ${ETCD_ENDPOINT}"
    echo "Root 用户名: ${ROOT_USERNAME}"
    
    # 检查 etcd 服务状态
    if ! check_etcd_health; then
        exit 1
    fi
    
    # 检查认证状态
    local auth_status
    if is_auth_enabled; then
        auth_status="enabled"
    else
        auth_status="disabled"
    fi
    
    # 如果认证已启用，检查 root 用户是否存在
    if [ "$${auth_status}" = "enabled" ]; then
        echo "认证已启用，检查 root 用户状态..."
        if verify_auth_config; then
            echo "🎉 etcd root 用户配置完成！"
            echo "用户名: ${ROOT_USERNAME}"
            echo "密码: ${ROOT_PASSWORD}"
            echo "认证已启用"
        else
            echo "❌ 配置完成但验证失败，请检查 etcd 日志"
            exit 1
        fi

    else
        # 创建 root 用户（幂等：如果用户已存在会失败，但前面已经检查过）
        if ! create_user ${ROOT_USERNAME} ${ROOT_PASSWORD}; then
            echo "⚠ 用户可能已存在，继续尝试授予权限..."
        fi
        # 授予 root 权限
        if ! grant_user_role ${ROOT_USERNAME} root; then
            echo "⚠ 权限可能已授予，继续验证..."
        fi

        # 创建 monitor 用户（幂等：如果用户已存在会失败，但前面已经检查过）
        if ! create_user ${MONITOR_USERNAME} ${MONITOR_PASSWORD}; then
            echo "⚠ 创建 monitor 用户 有问题"
        fi
        # 创建 monitor 角色
        if ! create_role role_monitor; then
            echo "⚠ 创建 monitor 角色 有问题"
        fi
        # 配置 monitor 角色权限
        if ! grant_role_permission role_monitor / AA== READ; then
            echo "⚠ 配置 monitor 角色权限 有问题"
        fi
        # 指定 monitor 角色
        if ! grant_user_role ${MONITOR_USERNAME} role_monitor; then
            echo "⚠指定 monitor 角色 有问题"
        fi

        # 认证未启用，先启用认证
        if ! enable_auth; then
            exit 1
        fi
        # 验证配置
        if verify_auth_config; then
            echo "🎉 etcd root 用户配置完成！"
            echo "用户名: ${ROOT_USERNAME}"
            echo "密码: ${ROOT_PASSWORD}"
            echo "认证已启用"
        else
            echo "❌ 配置完成但验证失败，请检查 etcd 日志"
            exit 1
        fi
    fi

}

# 异常处理
handle_error() {
    echo "❌ 脚本执行出错，退出状态: $?"
    exit 1
}

# 设置异常处理
trap handle_error ERR

# 执行主函数
main "$@"