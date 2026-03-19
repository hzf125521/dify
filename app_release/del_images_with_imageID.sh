#!/bin/bash

#===============================================================================
# Script Name: docker_rm_images.sh
# Description: 批量删除指定的 Docker 镜像 (通过 IMAGE ID)
# Usage: ./docker_rm_images.sh
# Attention: 请确保已提供正确的 IMAGE ID 列表，并注意镜像间的依赖关系。
#===============================================================================

# 定义要删除的 IMAGE ID 列表 (请根据实际情况修改或扩展)
IMAGE_IDS=(
    "c1f929f402ff"
    "95a8d298397e"
    "c138e8c0e115"
    "b64188dea470"
    "e9b629cccbe7"
    "98c26d3e4fd7"
    "ba1b250b9505"
    "f24b5f0e68e6"
    "af3f0f48a24e"
)

# 计数器：记录成功和失败的删除操作
SUCCESS_COUNT=0
FAIL_COUNT=0

# 打印开始信息
echo "========================================="
echo "开始批量删除 Docker 镜像"
echo "共 ${#IMAGE_IDS[@]} 个镜像待处理"
echo "========================================="

# 遍历列表中的每个 IMAGE ID
for IMAGE_ID in "${IMAGE_IDS[@]}"; do
    echo "正在尝试删除镜像: $IMAGE_ID"
    
    # 执行删除命令，并捕获输出和返回值
    # 使用 --force 强制删除（即使有容器使用该镜像也会强制移除，谨慎使用！）
    # 如果希望更安全，可以移除 --force 选项
    OUTPUT=$(docker rmi --force "$IMAGE_ID" 2>&1)
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "  [成功] 镜像 $IMAGE_ID 已删除"
        echo "  输出: $OUTPUT"
        ((SUCCESS_COUNT++))
    else
        echo "  [失败] 镜像 $IMAGE_ID 删除失败"
        echo "  错误信息: $OUTPUT"
        ((FAIL_COUNT++))
    fi
    echo "-----------------------------------------"
done

# 打印汇总结果
echo "========================================="
echo "批量删除操作完成"
echo "成功: $SUCCESS_COUNT"
echo "失败: $FAIL_COUNT"
echo "========================================="

# 如果存在失败项，提供额外检查建议
if [ $FAIL_COUNT -gt 0 ]; then
    echo "提示：删除失败可能原因："
    echo "  1. 镜像不存在"
    echo "  2. 镜像被容器使用（即使使用了 --force，某些情况仍可能失败）"
    echo "  3. Docker 守护进程未运行或无权限"
    echo "建议手动检查：docker images | grep -E \"$(IFS='|'; echo "${IMAGE_IDS[*]}")\""
fi