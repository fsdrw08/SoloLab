#!/bin/bash

# 安装 HashiCorp nomad 脚本
# 需要环境变量：
#   nomad_download_url - nomad 下载 URL（ZIP 格式）
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
if [ -z "$nomad_download_url" ]; then
    error_exit "环境变量 nomad_download_url 未设置"
fi

if [ -z "$custom_bin_dir" ]; then
    error_exit "环境变量 custom_bin_dir 未设置"
fi

info "开始安装 nomad..."
info "下载 URL: $nomad_download_url"
info "安装目录: $custom_bin_dir"

# 创建目标目录（如果不存在）
if [ ! -d "$custom_bin_dir" ]; then
    info "创建目录: $custom_bin_dir"
    mkdir -p "$custom_bin_dir" || error_exit "无法创建目录 $custom_bin_dir"
fi

# 提取文件名
filename=$(basename "$nomad_download_url")
tmp_zip="/tmp/$filename"

# 下载 nomad ZIP 文件
info "下载 nomad 到 $tmp_zip"
curl -L -o "$tmp_zip" "$nomad_download_url" || error_exit "下载失败"

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

# 查找解压出的 nomad 二进制文件（可能包含路径）
nomad_bin=""
if [ -f "$custom_bin_dir/nomad" ]; then
    nomad_bin="$custom_bin_dir/nomad"
elif [ -f "$custom_bin_dir/nomad.exe" ]; then
    nomad_bin="$custom_bin_dir/nomad.exe"
else
    # 尝试查找子目录中的 nomad 文件
    nomad_bin=$(find "$custom_bin_dir" -name "nomad" -type f -print -quit 2>/dev/null)
    if [ -z "$nomad_bin" ]; then
        nomad_bin=$(find "$custom_bin_dir" -name "nomad.exe" -type f -print -quit 2>/dev/null)
    fi
fi

if [ -z "$nomad_bin" ]; then
    error_exit "未找到 nomad 二进制文件"
fi

info "找到 nomad 二进制文件: $nomad_bin"

# 设置执行权限
info "设置执行权限: $nomad_bin"
chmod +x "$nomad_bin" || error_exit "无法设置执行权限"

# 更改 owner 为 root:root（需要 root 权限）
info "更改 owner 为 root:root: $nomad_bin"
chown root:root "$nomad_bin" 2>/dev/null || {
    echo "警告: 无法更改 owner 为 root:root，可能需要 root 权限" >&2
    echo "请使用 sudo 运行此脚本" >&2
}

# 删除下载的 ZIP 文件
info "删除临时文件: $tmp_zip"
rm -f "$tmp_zip" || error_exit "无法删除临时文件"

# 验证安装
if [ -x "$nomad_bin" ]; then
    info "nomad 安装成功！"
    "$nomad_bin" --version || error_exit "无法运行 nomad"
else
    error_exit "nomad 安装验证失败"
fi

info "完成"