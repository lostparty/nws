#!/bin/bash

# 调整 ping_group_range
echo "Checking current ping_group_range..."
current_range=$(cat /proc/sys/net/ipv4/ping_group_range)
echo "Current ping_group_range: $current_range"

if [ "$current_range" != "0 65535" ]; then
  echo "Setting ping_group_range to '0 65535'..."
  echo "0 65535" | sudo tee /proc/sys/net/ipv4/ping_group_range
  echo "Making the change persistent..."
  echo "net.ipv4.ping_group_range = 0 65535" | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
else
  echo "ping_group_range is already properly configured."
fi

# 增加接收缓冲区大小
echo "Increasing receive buffer size..."
sudo sysctl -w net.core.rmem_max=2621440
sudo sysctl -w net.core.rmem_default=2621440
echo 'net.core.rmem_max=2621440' | sudo tee -a /etc/sysctl.conf
echo 'net.core.rmem_default=2621440' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 检查网络连接和端口
echo "Ensuring QUIC ports are open in the firewall..."
sudo iptables -A INPUT -p udp --dport 4433 -j ACCEPT
sudo iptables -A OUTPUT -p udp --dport 4433 -j ACCEPT

# 测试网络连接
echo "Testing network connectivity..."
ping -c 4 8.8.8.8
ping -c 4 update.argotunnel.com

if [ $? -eq 0 ]; then
  echo "Network connectivity is fine."
else
  echo "Network connectivity issues detected. Please check your network settings."
fi

echo "Configuration complete. Please restart cloudflared to apply the changes."

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
