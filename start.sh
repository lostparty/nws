#!/bin/sh

# 提高 UDP 缓冲区大小
sysctl -w net.core.rmem_max=2500000
sysctl -w net.core.rmem_default=2500000

# 确保 ICMP 代理可以工作
echo "0 2147483647" > /proc/sys/net/ipv4/ping_group_range

# 创建一个唯一的子目录
WORK_DIR="/tmp/web-deploy-$$"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 复制 server.zip 文件到临时目录
cp /app/server.zip "$WORK_DIR"

# 下载并设置 web 文件的可执行权限
if wget -O temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip; then
    unzip temp.zip xray
    unzip server.zip server
    mv xray web
    chmod +x web
    chmod +x server
else
    echo "Failed to download or extract Xray."
    exit 1
fi

# 启动 Node.js 应用
nohup node /app/index.js > output.log 2>&1 &

# 等待 web 服务启动
sleep 2

# 启动 web 应用
echo "----- Starting web ... -----"
nohup ./web run -config /app/config.json > web.log 2>&1 &

# 启动 server 隧道服务
./server tunnel --edge-ip-version auto run --token eyJhIjoiYjQ2N2Q5MGUzZDYxNWFhOTZiM2ZmODU5NzZlY2MxZjgiLCJ0IjoiNTZkMzMzYzEtMzJiNS00YzY2LWE3NDgtOTcwMDlkODExNjY3IiwicyI6Ik1tWXpNREUzT0RrdE1URTROQzAwTkRSbExXRTNNVE10T0dFMk9HVXlaalUyWVdFdyJ9

# 保持容器运行
tail -f /dev/null
