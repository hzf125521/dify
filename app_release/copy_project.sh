#!/bin/bash

# 定义路径
APP_RELEASE_DIR="/home/ms28175/dify/app_release"
DOCKER_DIR="/home/ms28175/dify/docker"

echo "========================================="
echo "复制项目目录"
echo "========================================="

read -p "请输入上一层文件夹的名称 (例如输入 'xxx' 将会复制到 $APP_RELEASE_DIR/app/xxx/docker): " target_folder_name

if [ -z "$target_folder_name" ]; then
    echo "未输入文件夹名称，取消复制操作。"
else
    TARGET_PARENT_DIR="$APP_RELEASE_DIR/app/$target_folder_name"
    
    echo "正在使用 sudo 创建目录并复制 $DOCKER_DIR 到 $TARGET_PARENT_DIR ..."
    sudo mkdir -p "$TARGET_PARENT_DIR"
    
    if sudo cp -a "$DOCKER_DIR" "$TARGET_PARENT_DIR/"; then
        echo "复制成功！文件夹已被复制到: $TARGET_PARENT_DIR/docker"
        echo ""
        echo -e "\033[1;31m════════════════════════════════════════════════════════════════"
        echo -e "⚠️  警告：请在开发环境中启动Copy后的Dify，进入Web界面删除无关应用和敏感Keys"
        echo -e "════════════════════════════════════════════════════════════════\033[0m"
    else
        echo "复制失败，请检查 sudo 权限或目录状态！"
    fi
fi
