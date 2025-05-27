#!/bin/bash
set -e

# 允许 SSHD 同时监听多个端口
sed -i '/^#Port 22/s/^#//' /etc/ssh/sshd_config
grep -q "^Port 1022" /etc/ssh/sshd_config || echo "Port 1022" >> /etc/ssh/sshd_config
grep -q "^Port 1122" /etc/ssh/sshd_config || echo "Port 1122" >> /etc/ssh/sshd_config

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
