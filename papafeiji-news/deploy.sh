#!/bin/bash
# 部署脚本：papafeiji-news (Astro 静态站点) 部署到 47.98.121.243

set -e

SERVER="root@47.98.121.243"
PASSWORD="ppfj2025!"
REMOTE_DIR="/var/www/papafeiji-news"
PORT=8080
LOCAL_DIR="/root/papafeiji-news"
DOMAIN="news.papafeiji.cn"

SSH_PREFIX="sshpass -p '${PASSWORD}' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15"

echo "=== 本地构建 ==="
cd "$LOCAL_DIR"
npm install
npm run build

echo "=== 安装 nginx（如未安装）==="
eval "${SSH_PREFIX} ${SERVER} 'which nginx || (apt-get update && apt-get install -y nginx && systemctl enable nginx)'"

echo "=== 同步构建产物到服务器 ==="
sshpass -p "${PASSWORD}" rsync -avz --delete \
  -e "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15" \
  "${LOCAL_DIR}/dist/" "${SERVER}:${REMOTE_DIR}/"

echo "=== 检查/创建 nginx 配置 ==="
eval "${SSH_PREFIX} ${SERVER} '
if [ ! -f /etc/nginx/sites-enabled/papafeiji-news ]; then
  cat > /etc/nginx/sites-available/papafeiji-news << NGINX_EOF
server {
    listen 80;
    server_name ${DOMAIN};
    root ${REMOTE_DIR};
    index index.html;
    location / {
        try_files \\\$uri \\\$uri/ =404;
    }
}
NGINX_EOF
  ln -sf /etc/nginx/sites-available/papafeiji-news /etc/nginx/sites-enabled/papafeiji-news
fi
nginx -t && systemctl reload nginx'"

echo "=== 部署完成 ==="
echo "访问地址: https://${DOMAIN}"
