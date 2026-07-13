#!/bin/bash
# 部署脚本：papafeiji-officialwebsite (官网)
# 支持：首次全新部署 与 后续版本更新
# 用法：bash deploy.sh

set -e

# ═══════════════════════════════════════════
# 配置区
# ═══════════════════════════════════════════
SERVER="root@47.98.121.243"
PASSWORD="ppfj2025!"
LOCAL_DIR="$(dirname "$(readlink -f "$0")")"

# 官网
REMOTE_DIR="/var/www/papafeiji-officialwebsite"
DOMAIN="papafeiji.cn"
EXPECTED_IP="47.98.121.243"
SSL_EMAIL="admin@papafeiji.cn"

# SSH 连接选项（为自动化部署忽略 known_hosts 检查，并抑制非错误日志）
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 -o LogLevel=ERROR"

# ═══════════════════════════════════════════
# 日志与工具函数
# ═══════════════════════════════════════════
log_step() {
  echo ""
  echo "=== $1 ==="
}

log_info() {
  echo "[INFO] $1"
}

log_warn() {
  echo "[WARN] $1" >&2
}

log_error() {
  echo "[ERROR] $1" >&2
}

run_remote() {
  # 在远程服务器执行命令，自动处理 sshpass
  sshpass -p "${PASSWORD}" ssh ${SSH_OPTS} "${SERVER}" "$@"
}

# 检测是否为首次部署
is_first_deploy() {
  if run_remote "test -f ${REMOTE_DIR}/index.html" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

# ═══════════════════════════════════════════
# 本地环境检查与安装
# ═══════════════════════════════════════════
install_local_pkg() {
  local pkg="$1"
  log_info "正在安装 ${pkg}..."
  if [ "$(id -u)" -eq 0 ]; then
    if command -v apt-get >/dev/null 2>&1; then
      apt-get update -qq && apt-get install -y "${pkg}"
    elif command -v yum >/dev/null 2>&1; then
      yum install -y "${pkg}"
    else
      return 1
    fi
  else
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -qq && sudo apt-get install -y "${pkg}"
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y "${pkg}"
    else
      return 1
    fi
  fi
}

check_local_env() {
  log_step "检查本地环境"

  if ! command -v node >/dev/null 2>&1; then
    log_error "本地未安装 Node.js，请先安装 Node.js"
    exit 1
  fi

  if ! command -v npm >/dev/null 2>&1; then
    log_error "本地未安装 npm，请先安装 npm"
    exit 1
  fi

  if ! command -v sshpass >/dev/null 2>&1; then
    install_local_pkg sshpass || {
      log_error "无法自动安装 sshpass，请手动安装后重试"
      exit 1
    }
  fi

  if ! command -v rsync >/dev/null 2>&1; then
    install_local_pkg rsync || {
      log_error "无法自动安装 rsync，请手动安装后重试"
      exit 1
    }
  fi
}

# ═══════════════════════════════════════════
# 前置检查
# ═══════════════════════════════════════════
check_dns() {
  log_step "检查域名解析"
  if ! getent hosts "${DOMAIN}" | grep -q "${EXPECTED_IP}"; then
    log_error "${DOMAIN} 未解析到 ${EXPECTED_IP}"
    log_error "请先将域名 DNS 的 A 记录指向 ${EXPECTED_IP}，再执行部署"
    exit 1
  fi
  log_info "${DOMAIN} 已正确解析到 ${EXPECTED_IP}"
}

check_ssh() {
  log_step "检查服务器 SSH 连通性"
  if ! run_remote "echo ok" >/dev/null 2>&1; then
    log_error "无法通过 SSH 连接到 ${SERVER}，请检查密码、网络和安全组 22 端口"
    exit 1
  fi
  log_info "SSH 连接正常"
}

# ═══════════════════════════════════════════
# 本地构建
# ═══════════════════════════════════════════
build_main() {
  log_step "本地构建官网"
  cd "$LOCAL_DIR"
  npm install
  npm run build

  if [ ! -d "${LOCAL_DIR}/out" ]; then
    log_error "构建后未找到 ${LOCAL_DIR}/out 目录"
    exit 1
  fi
}

# ═══════════════════════════════════════════
# nginx 管理
# ═══════════════════════════════════════════
ensure_nginx() {
  log_step "确保 nginx 已安装并运行"

  local nginx_installed
  nginx_installed=$(run_remote "command -v nginx >/dev/null 2>&1 && echo yes || echo no")

  if [ "${nginx_installed}" != "yes" ]; then
    log_info "nginx 未安装，正在安装..."
    run_remote "
      export DEBIAN_FRONTEND=noninteractive
      apt-get update && apt-get install -y nginx && systemctl enable nginx
    "
  else
    log_info "nginx 已安装"
  fi

  run_remote "systemctl start nginx"
}

sync_main() {
  log_step "同步官网构建产物到服务器"
  sshpass -p "${PASSWORD}" rsync -avz --delete \
    -e "ssh ${SSH_OPTS}" \
    "${LOCAL_DIR}/out/" "${SERVER}:${REMOTE_DIR}/"
  log_info "官网产物已同步到 ${REMOTE_DIR}"
}

ensure_nginx_config() {
  log_step "检查/创建 nginx 配置"

  # 备份旧配置（如果存在）
  run_remote "
    if [ -f /etc/nginx/sites-available/papafeiji-officialwebsite ]; then
      cp /etc/nginx/sites-available/papafeiji-officialwebsite \
         /etc/nginx/sites-available/papafeiji-officialwebsite.bak.$(date +%Y%m%d%H%M%S)
    fi
  "

  if [ "${first_deploy}" = "true" ]; then
    run_remote "cat > /etc/nginx/sites-available/papafeiji-officialwebsite << 'NGINX_EOF'
server {
    listen 80;
    server_name ${DOMAIN};
    root ${REMOTE_DIR};
    index index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX_EOF
ln -sf /etc/nginx/sites-available/papafeiji-officialwebsite /etc/nginx/sites-enabled/papafeiji-officialwebsite
nginx -t && systemctl reload nginx"
  else
    run_remote "cat > /etc/nginx/sites-available/papafeiji-officialwebsite << 'NGINX_EOF'
server {
    listen 443 ssl;
    server_name ${DOMAIN};
    root ${REMOTE_DIR};
    index index.html;
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}
NGINX_EOF
ln -sf /etc/nginx/sites-available/papafeiji-officialwebsite /etc/nginx/sites-enabled/papafeiji-officialwebsite
nginx -t && systemctl reload nginx"
  fi
}

# ═══════════════════════════════════════════
# SSL 证书管理（仅在首次部署时调用）
# ═══════════════════════════════════════════
ensure_ssl() {
  log_step "申请/部署 SSL 证书"

  # 确保证书工具已安装
  run_remote "
    export DEBIAN_FRONTEND=noninteractive
    if ! command -v certbot >/dev/null 2>&1; then
      apt-get update && apt-get install -y certbot python3-certbot-nginx
    fi
  "

  log_info "首次申请 SSL 证书..."
  run_remote "
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${SSL_EMAIL} --redirect
    systemctl enable certbot.timer 2>/dev/null || true
    systemctl start certbot.timer 2>/dev/null || true
    nginx -t && systemctl reload nginx
  "
}

# ═══════════════════════════════════════════
# 访问验证
# ═══════════════════════════════════════════
verify_access() {
  log_step "验证访问"
  local http_code tutorial_code

  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${DOMAIN}/" || echo "000")
  if [ "${http_code}" = "200" ]; then
    log_info "验证成功：https://${DOMAIN}/ 返回 200"
  else
    log_warn "https://${DOMAIN}/ 验证请求返回 ${http_code}，请手动检查"
  fi

  tutorial_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${DOMAIN}/tutorial/" || echo "000")
  if [ "${tutorial_code}" = "200" ]; then
    log_info "验证成功：https://${DOMAIN}/tutorial/ 返回 200"
  else
    log_warn "https://${DOMAIN}/tutorial/ 验证请求返回 ${tutorial_code}，请手动检查"
  fi
}

# ═══════════════════════════════════════════
# 主流程
# ═══════════════════════════════════════════
main() {
  first_deploy=false
  if is_first_deploy; then
    first_deploy=true
    log_info "检测到首次部署"
  else
    log_info "检测到更新部署"
  fi

  check_local_env
  check_dns
  check_ssh
  build_main
  ensure_nginx
  sync_main
  ensure_nginx_config
  if [ "${first_deploy}" = "true" ]; then
    ensure_ssl
  fi
  verify_access

  echo ""
  echo "=== 部署完成 ==="
  echo "官网访问地址: https://${DOMAIN}"
  echo "教程页面: https://${DOMAIN}/tutorial/"
  echo "证书覆盖域名: ${DOMAIN}"
}

main "$@"
