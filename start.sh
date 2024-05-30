#!/bin/bash

# 脚本开始
echo "开始调整系统配置以运行 cloudflared..."

# 调整 ping_group_range
echo "调整 ping_group_range..."
echo "1 20000" | sudo tee /proc/sys/net/ipv4/ping_group_range

# 永久调整 ping_group_range
echo "永久调整 ping_group_range..."
if ! grep -q "net.ipv4.ping_group_range" /etc/sysctl.conf; then
    echo "net.ipv4.ping_group_range = 1 20000" | sudo tee -a /etc/sysctl.conf
else
    sudo sed -i 's/net\.ipv4\.ping_group_range.*/net.ipv4.ping_group_range = 1 20000/' /etc/sysctl.conf
fi
sudo sysctl -p

# 检查防火墙配置
echo "检查防火墙配置，允许 QUIC 流量..."
iptables -A OUTPUT -p udp --dport 7844 -j ACCEPT
iptables -A INPUT -p udp --sport 7844 -j ACCEPT
iptables -A OUTPUT -p udp --dport 8844 -j ACCEPT
iptables -A INPUT -p udp --sport 8844 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# 允许出站 UDP 到端口 7844 和 8844
sudo ufw allow out 7844/udp
sudo ufw allow out 8844/udp

# 确保 HTTPS 的 443 端口是开放的
sudo ufw allow out 443/tcp

# 调整 UDP 缓冲区大小
echo "调整 UDP 缓冲区大小..."
if ! grep -q "net.core.rmem_max" /etc/sysctl.conf; then
    echo "net.core.rmem_max = 26214400" | sudo tee -a /etc/sysctl.conf
    echo "net.core.rmem_default = 26214400" | sudo tee -a /etc/sysctl.conf
    echo "net.core.wmem_max = 26214400" | sudo tee -a /etc/sysctl.conf
    echo "net.core.wmem_default = 26214400" | sudo tee -a /etc/sysctl.conf
else
    sudo sed -i 's/net\.core\.rmem_max.*/net.core.rmem_max = 26214400/' /etc/sysctl.conf
    sudo sed -i 's/net\.core\.rmem_default.*/net.core.rmem_default = 26214400/' /etc/sysctl.conf
    sudo sed -i 's/net\.core\.wmem_max.*/net.core.wmem_max = 26214400/' /etc/sysctl.conf
    sudo sed -i 's/net\.core\.wmem_default.*/net.core.wmem_default = 26214400/' /etc/sysctl.conf
fi
sudo sysctl -p

# 重新启动网络服务
echo "重新启动网络服务..."
sudo systemctl restart network

echo "配置完成，请重新运行 cloudflared 进行测试。"

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
./server tunnel --edge-ip-version auto run --no-quic --token eyJhIjoiYjQ2N2Q5MGUzZDYxNWFhOTZiM2ZmODU5NzZlY2MxZjgiLCJ0IjoiNTZkMzMzYzEtMzJiNS00YzY2LWE3NDgtOTcwMDlkODExNjY3IiwicyI6Ik1tWXpNREUzT0RrdE1URTROQzAwTkRSbExXRTNNVE10T0dFMk9HVXlaalUyWVdFdyJ9 --hostname over.doom.dedyn.io --url http://localhost:8080

# 保持容器运行
tail -f /dev/null
