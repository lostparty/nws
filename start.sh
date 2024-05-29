#!/bin/sh

# 切换到可写目录
cd /tmp

sudo cp /app/server.zip /tmp/

# 下载并设置 web 文件的可执行权限
wget -O temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
unzip temp.zip xray && \
unzip server.zip server && \
mv xray web && \
chmod +x web && \
chmod +x server

nohup node /app/index.js > output.log 2>&1 &

# 确保 web 服务启动后开始运行 node index.js
sleep 2  # 等待 web 服务真正启动。

# 启动 web 并将在后台运行
echo "----- Starting web ... -----"
nohup ./web run -config /app/config.json >web.log 2>&1 &

./server tunnel --edge-ip-version auto run --token eyJhIjoiYjQ2N2Q5MGUzZDYxNWFhOTZiM2ZmODU5NzZlY2MxZjgiLCJ0IjoiNTZkMzMzYzEtMzJiNS00YzY2LWE3NDgtOTcwMDlkODExNjY3IiwicyI6Ik1tWXpNREUzT0RrdE1URTROQzAwTkRSbExXRTNNVE10T0dFMk9HVXlaalUyWVdFdyJ9

# 保持容器运行
tail -f /dev/null
