#!/bin/bash

# 安装 HashiCorp Consul 脚本
# 需要环境变量：
#   consul_download_url - Consul 下载 URL（ZIP 格式）
#   custom_bin_dir     - 二进制文件安装目录

set -e  # 遇到错误立即退出

# 颜色输出函数
error_exit() {
    echo "错误: $1" >&2
    exit 1
}

info() {
    echo "信息: $1"
}

# 检查必需的环境变量
if [ -z "$consul_download_url" ]; then
    error_exit "环境变量 consul_download_url 未设置"
fi

if [ -z "$custom_bin_dir" ]; then
    error_exit "环境变量 custom_bin_dir 未设置"
fi

info "开始安装 Consul..."
info "下载 URL: $consul_download_url"
info "安装目录: $custom_bin_dir"

# 创建目标目录（如果不存在）
if [ ! -d "$custom_bin_dir" ]; then
    info "创建目录: $custom_bin_dir"
    mkdir -p "$custom_bin_dir" || error_exit "无法创建目录 $custom_bin_dir"
fi

# 提取文件名
filename=$(basename "$consul_download_url")
tmp_zip="/tmp/$filename"

# 下载 Consul ZIP 文件
info "下载 Consul 到 $tmp_zip"
curl -L -o "$tmp_zip" "$consul_download_url" || error_exit "下载失败"

# 检查文件是否下载成功
if [ ! -f "$tmp_zip" ]; then
    error_exit "下载的文件不存在"
fi

# 检查 bsdtar 是否可用
if ! command -v bsdtar &> /dev/null; then
    error_exit "bsdtar 未安装，请先安装 libarchive-tools (Ubuntu/Debian) 或 bsdtar (macOS/FreeBSD)"
fi

# 使用 bsdtar 解压 ZIP 文件
info "解压 $tmp_zip"
bsdtar -xf "$tmp_zip" -C "$custom_bin_dir" || error_exit "解压失败"

# 查找解压出的 consul 二进制文件（可能包含路径）
consul_bin=""
if [ -f "$custom_bin_dir/consul" ]; then
    consul_bin="$custom_bin_dir/consul"
elif [ -f "$custom_bin_dir/consul.exe" ]; then
    consul_bin="$custom_bin_dir/consul.exe"
else
    # 尝试查找子目录中的 consul 文件
    consul_bin=$(find "$custom_bin_dir" -name "consul" -type f -print -quit 2>/dev/null)
    if [ -z "$consul_bin" ]; then
        consul_bin=$(find "$custom_bin_dir" -name "consul.exe" -type f -print -quit 2>/dev/null)
    fi
fi

if [ -z "$consul_bin" ]; then
    error_exit "未找到 consul 二进制文件"
fi

info "找到 consul 二进制文件: $consul_bin"

# 设置执行权限
info "设置执行权限: $consul_bin"
chmod +x "$consul_bin" || error_exit "无法设置执行权限"

# 更改 owner 为 root:root（需要 root 权限）
info "更改 owner 为 root:root: $consul_bin"
chown root:root "$consul_bin" 2>/dev/null || {
    echo "警告: 无法更改 owner 为 root:root，可能需要 root 权限" >&2
    echo "请使用 sudo 运行此脚本" >&2
}

# 删除下载的 ZIP 文件
info "删除临时文件: $tmp_zip"
rm -f "$tmp_zip" || error_exit "无法删除临时文件"

# 验证安装
if [ -x "$consul_bin" ]; then
    info "Consul 安装成功！"
    "$consul_bin" --version || error_exit "无法运行 consul"
else
    error_exit "Consul 安装验证失败"
fi

info "完成"