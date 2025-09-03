#!/bin/bash

# 幂等的创建 etcd root 用户并赋予 root 权限的脚本
set -euo pipefail

# 配置参数
ETCD_ENDPOINT="${ETCD_ENDPOINT:-http://localhost:2379}"
ROOT_USERNAME="${ROOT_USERNAME:-root}"
ROOT_PASSWORD="${ROOT_PASSWORD:-root123}"
AUTH_ENABLED_FLAG_FILE="/tmp/etcd_auth_enabled.flag"

# 函数：检查 etcd 是否可用
check_etcd_health() {
    echo "检查 etcd 服务状态..."
    if curl -s -f "${ETCD_ENDPOINT}/health" | grep -q '"health":"true"'; then
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
    response=$(curl -s "${ETCD_ENDPOINT}/v3/auth/status" -X POST 2>/dev/null || true)
    
    if echo "${response}" | grep -q '"enabled":true'; then
        echo "✓ 认证已启用"
        return 0
    elif echo "${response}" | grep -q '"enabled":false'; then
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
    response=$(curl -s "${ETCD_ENDPOINT}/v3/auth/user/get" -X POST \
        -d "{\"name\": \"${username}\"}" 2>/dev/null || true)
    
    if echo "${response}" | grep -q "\"name\":\"${username}\""; then
        return 0
    else
        return 1
    fi
}

# 函数：启用认证
enable_auth() {
    echo "启用 etcd 认证..."
    if curl -s -f "${ETCD_ENDPOINT}/v3/auth/enable" -X POST; then
        echo "✓ 认证启用成功"
        touch "${AUTH_ENABLED_FLAG_FILE}"
        return 0
    else
        echo "✗ 认证启用失败"
        return 1
    fi
}

# 函数：创建 root 用户
create_root_user() {
    echo "创建 root 用户: ${ROOT_USERNAME}"
    
    if curl -s -f "${ETCD_ENDPOINT}/v3/auth/user/add" -X POST \
        -d "{\"name\": \"${ROOT_USERNAME}\", \"password\": \"${ROOT_PASSWORD}\"}"; then
        echo "✓ root 用户创建成功"
        return 0
    else
        echo "✗ root 用户创建失败"
        return 1
    fi
}

# 函数：授予 root 权限
grant_root_role() {
    echo "为用户 ${ROOT_USERNAME} 授予 root 角色..."
    
    if curl -s -f "${ETCD_ENDPOINT}/v3/auth/user/grant" -X POST \
        -d "{\"user\": \"${ROOT_USERNAME}\", \"role\": \"root\"}"; then
        echo "✓ root 权限授予成功"
        return 0
    else
        echo "✗ root 权限授予失败"
        return 1
    fi
}

# 函数：验证认证配置
verify_auth_config() {
    echo "验证认证配置..."
    
    # 使用 root 用户执行一个需要权限的操作来验证
    local auth_header
    auth_header="Authorization: Basic $(echo -n "${ROOT_USERNAME}:${ROOT_PASSWORD}" | base64)"
    
    if curl -s -f "${ETCD_ENDPOINT}/v3/auth/user/list" -X POST \
        -H "${auth_header}" | grep -q "\"users\":"; then
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
    if [ "${auth_status}" = "enabled" ]; then
        echo "认证已启用，检查 root 用户状态..."
        if user_exists "${ROOT_USERNAME}"; then
            echo "✓ root 用户已存在，跳过创建"
            echo "配置完成（无需变更）"
            exit 0
        else
            echo "⚠ 认证已启用但 root 用户不存在，尝试创建..."
        fi
    else
        # 认证未启用，先启用认证
        if ! enable_auth; then
            exit 1
        fi
    fi
    
    # 创建 root 用户（幂等：如果用户已存在会失败，但前面已经检查过）
    if ! create_root_user; then
        echo "⚠ 用户可能已存在，继续尝试授予权限..."
    fi
    
    # 授予 root 权限
    if ! grant_root_role; then
        echo "⚠ 权限可能已授予，继续验证..."
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