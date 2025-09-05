#!/bin/bash

set -e

# 定义变量
TARGET_DIR="${TARGET_DIR}"
LINK_PATH="${LINK_PATH}"

# 创建目标目录（如果不存在）
sudo mkdir -p "$TARGET_DIR"
echo "ensure target dir exist $TARGET_DIR"

# 检查软连接是否已存在且正确
if [ -L "$LINK_PATH" ]; then
    # 验证现有软连接是否正确指向目标
    existing_target=$(readlink -f "$LINK_PATH")
    if [ "$existing_target" = "$TARGET_DIR" ]; then
        echo "symlink is exist and correct: $LINK_PATH -> $TARGET_DIR"
        exit 0
    else
        echo "symlink is incorrect, recreate..."
        sudo rm -f "$LINK_PATH"
        sudo ln -sf "$TARGET_DIR" "$LINK_PATH"
        echo "symlink updated: $LINK_PATH -> $TARGET_DIR"
    fi
elif [ -e "$LINK_PATH" ]; then
    # 如果存在但不是软连接（可能是文件或目录）
    echo "caution: $LINK_PATH is exist but not a symlink"
    echo "rename the file..."
    sudo mv "$LINK_PATH" "$${LINK_PATH}.bak.$(date +%Y%m%d%H%M%S)"
    sudo ln -sf "$TARGET_DIR" "$LINK_PATH"
    echo "old file renamed, symlink created: $LINK_PATH -> $TARGET_DIR"
else
    # 创建新的软连接
    sudo ln -sf "$TARGET_DIR" "$LINK_PATH"
    echo "symlink created: $LINK_PATH -> $TARGET_DIR"
fi

# 设置正确的权限（可选）
sudo chown -R core:core "/var/home/core/.local" 2>/dev/null || true

echo "done"