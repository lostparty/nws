#!/bin/sh

# 切换到可写目录
cd /tmp

# 下载并设置 web 文件的可执行权限
wget -O temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
unzip temp.zip xray && \
mv xray web && \
chmod +x web

# 启动 web 并将在后台运行
echo "----- Starting web ... -----"
nohup ./web run -config /app/config.json >web.log 2>&1 &

# 确保 web 服务启动后开始运行 node index.js
sleep 2  # 等待 web 服务真正启动。

# 启动 Node.js 应用
node /app/index.js &

# 保持容器运行
tail -f /dev/null
