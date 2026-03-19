1. 迁移dify的前提
启动/home/ms28175/dify/docker/docker-compose.yaml，dify服务正常运行

2. 执行export_images_and_copy.sh脚本
./export_images_and_copy.sh
2.1根据/home/ms28175/dify/docker/docker-compose.yaml中的images和docker中实际使用的images，导出相关镜像
2.2复制整个/home/ms28175/dify/docker文件夹至/home/ms28175/dify/app_release/app中

3. 启动/home/ms28175/dify/app_release/app中复制过来的docker-compose.yaml
正常启动后，登录dify:
xst.admin@moons.com.cn
shSH125521**

删除无关应用和敏感Keys