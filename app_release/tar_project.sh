#!/bin/bash

# 定义路径
SOURCE_DIR="/home/ms28175/dify/app_release/app"
DEST_DIR="/mnt/f/company/project/dify_app_release/app"

echo "========================================="
echo "打包并导出项目应用"
echo "========================================="

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录 $SOURCE_DIR 不存在"
    exit 1
fi

# 检查目标目录是否存在，如果不存在则创建
if [ ! -d "$DEST_DIR" ]; then
    echo "目标目录 $DEST_DIR 不存在，正在尝试创建..."
    mkdir -p "$DEST_DIR"
    if [ $? -ne 0 ]; then
        echo "错误: 无法创建目标目录，请检查权限或路径是否正确 (例如 F 盘是否已挂载)。"
        exit 1
    fi
    echo "已创建目标目录。"
fi

echo "正在扫描 $SOURCE_DIR 下的项目目录..."

# 切换到源目录以方便获取相对路径
cd "$SOURCE_DIR" || exit 1

# 获取所有子目录名称
# 使用 find 查找一级目录，并去除开头的 ./
mapfile -t DIR_ARRAY < <(find . -maxdepth 1 -mindepth 1 -type d -printf '%P\n' | sort)

if [ ${#DIR_ARRAY[@]} -eq 0 ]; then
    echo "在 $SOURCE_DIR 下未找到任何子目录。"
    exit 0
fi

echo "请选择要打包的项目目录 (输入数字):"
select dir in "${DIR_ARRAY[@]}"; do
    if [ -n "$dir" ]; then
        echo "您选择了: $dir"
        
        # 生成带时间戳的文件名
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        TGZ_FILENAME="${dir}_${TIMESTAMP}.tgz"
        TGZ_FILEPATH="$DEST_DIR/$TGZ_FILENAME"
        
        echo "正在打包 $dir 并直接导出到 $TGZ_FILEPATH ..."
        echo "此过程直接写入目标路径，不会在 WSL 中留存副本。"
        
        # 打包并压缩，直接输出到目标路径
        # 使用 sudo 以确保有权限读取 docker/volumes 下的受保护文件
        # 使用重定向 > 将输出写入目标文件，确保目标文件权限归当前用户所有（且避免 root 在 /mnt/f 写入可能的问题）
        if sudo tar -czf - "$dir" > "$TGZ_FILEPATH"; then
            echo "-----------------------------------------"
            echo "✅ 打包成功！"
            echo "文件路径: $TGZ_FILEPATH"
            echo "Windows 路径: F:\\company\\project\\dify_app_release\\app\\$TGZ_FILENAME"
            echo "-----------------------------------------"
        else
            echo "❌ 打包失败！请检查目标路径写入权限。"
            exit 1
        fi
        break
    else
        echo "无效的选择，请重试。"
    fi
done

echo ""
echo "按任意键退出..."
read -n 1 -s
