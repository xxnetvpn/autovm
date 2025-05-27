#!/bin/bash
set -e

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
