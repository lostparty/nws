#!/bin/sh

# 切换到可写目录
cd /tmp

# 下载并设置 web 文件的可执行权限
wget -O temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
wget -O server https://github.com/cloudflare/cloudflared/releases/download/2024.5.0/cloudflared-linux-amd64 && \
unzip temp.zip xray && \
mv xray web && \
chmod +x web && \
chmod +x server

# 启动 web 并将在后台运行
echo "----- Starting web ... -----"
nohup ./web run -config /app/config.json >web.log 2>&1 &

# 启动 server 并将在后台运行
echo "----- Starting server ... -----"
Token=${Token:-'eyJhIjoiYjQ2N2Q5MGUzZDYxNWFhOTZiM2ZmODU5NzZlY2MxZjgiLCJ0IjoiNTZkMzMzYzEtMzJiNS00YzY2LWE3NDgtOTcwMDlkODExNjY3IiwicyI6Ik1tWXpNREUzT0RrdE1URTROQzAwTkRSbExXRTNNVE10T0dFMk9HVXlaalUyWVdFdyJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token >server.log 2>&1 &

# 确保 web 服务启动后开始运行 node index.js
sleep 2  # 等待 web 服务真正启动。

# 启动 Node.js 应用
node /app/index.js &

# 保持容器运行
tail -f /dev/null
