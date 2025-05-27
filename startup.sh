#!/bin/bash
set -e

# 获取 PORTS 环境变量（从 GCP metadata）
PORTS=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/PORTS" -H "Metadata-Flavor: Google")

# 清除已有 Port 配置
sed -i '/^Port /d' /etc/ssh/sshd_config

# 添加多端口监听配置
for PORT in $PORTS; do
  echo "Port $PORT" >> /etc/ssh/sshd_config
done

# 重启 SSH 服务以应用更改
systemctl restart ssh

# 创建 lastrun.sh 脚本
cat << 'EOF' > /usr/local/bin/lastrun.sh
#!/bin/bash
echo "Running lastrun service at $(date)" >> /var/log/lastrun.log
EOF

chmod +x /usr/local/bin/lastrun.sh

# 创建 systemd 服务单元
cat << 'EOF' > /etc/systemd/system/lastrun.service
[Unit]
Description=Last run service
DefaultDependencies=no
After=multi-user.target
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/lastrun.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable lastrun.service
systemctl start lastrun.service
