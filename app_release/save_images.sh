#!/bin/bash

# 定义路径
COMPOSE_FILE="/home/ms28175/dify/docker/docker-compose.yaml"
APP_RELEASE_DIR="/home/ms28175/dify/app_release"
IMAGES_DIR="$APP_RELEASE_DIR/images"

echo "========================================="
echo "导出 Docker 镜像"
echo "========================================="

echo "正在检查并读取 $COMPOSE_FILE 中的 image 名称..."
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "错误: 找不到文件 $COMPOSE_FILE"
    exit 1
fi

# 1. 从 docker-compose.yaml 提取所有 image 名称
# 使用 grep 查找以 image: 开头的行，提取其后的镜像名称，去除单双引号，并使用 sort -u 去重
COMPOSE_IMAGES=$(grep -E '^[[:space:]]*image:' "$COMPOSE_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'" | sort -u)

echo "正在获取当前 Docker 环境已导入的 images..."
# 获取当前本地所有镜像，格式为 "仓库:标签"
LOCAL_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}")

MATCHING_IMAGES=()
echo "========================================="
echo "在 docker-compose.yaml 和本地环境中同时存在的 images:"

for img in $COMPOSE_IMAGES; do
    # 去除空行
    if [ -z "$img" ]; then continue; fi
    
    # 如果 compose 文件中没有指定 tag，默认为 latest
    if [[ ! "$img" == *":"* ]]; then
        img="${img}:latest"
    fi
    
    # 检查本地镜像列表中是否存在该镜像
    if echo "$LOCAL_IMAGES" | grep -qFx "$img"; then
        echo " - $img"
        MATCHING_IMAGES+=("$img")
    fi
done

echo "========================================="

# 如果没有匹配的镜像
if [ ${#MATCHING_IMAGES[@]} -eq 0 ]; then
    echo "没有找到同时存在于配置文件和本地环境中的镜像。"
else
    # 2. 询问是否导出这些 images
    read -p "是否将上述这些 images 一起导出为一个完整的 .tgz 压缩文件？(y/n): " export_choice
    
    if [[ "$export_choice" == "y" || "$export_choice" == "Y" ]]; then
        
        # 3. 询问使用哪个镜像的版本号作为命名内容
        echo "请选择使用哪个 image 的版本号作为整个 tgz 文件的命名内容："
        select img_choice in "${MATCHING_IMAGES[@]}"; do
            if [ -n "$img_choice" ]; then
                # 提取版本号（冒号后面的部分）
                VERSION_TAG="${img_choice##*:}"
                echo "您选择了版本号: $VERSION_TAG"
                break
            else
                echo "无效的选择，请重试。"
            fi
        done
        
        # 确保存放路径存在
        mkdir -p "$IMAGES_DIR"
        
        # 生成时间戳及文件名
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        TGZ_FILENAME="image_xst_dify_${VERSION_TAG}_${TIMESTAMP}.tgz"
        TGZ_FILEPATH="$IMAGES_DIR/$TGZ_FILENAME"
        
        echo "正在导出并压缩为 $TGZ_FILEPATH，此过程可能需要几分钟时间，请耐心等待..."
        
        # 使用 docker save 导出所有匹配的镜像，并通过 gzip 压缩
        if docker save "${MATCHING_IMAGES[@]}" | gzip > "$TGZ_FILEPATH"; then
            echo "导出成功！文件已保存在: $TGZ_FILEPATH"
        else
            echo "导出失败，请检查 Docker 环境或磁盘空间！"
        fi
    else
        echo "已取消镜像导出操作。"
    fi
fi
