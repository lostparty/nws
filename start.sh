#!/bin/sh

# 下载并设置 web 文件的可执行权限
wget -O web https://github.com/wwrrtt/cyclic/raw/main/web && \
chmod +x web

# 启动 web 并将在后台运行
echo "-----  Starting web ... -----"
nohup ./web >web.log 2>&1 &

# 启动 Node.js 应用
echo "-----  Starting node index.js ... -----"
node index.js &

# 保持容器运行
tail -f /dev/null
