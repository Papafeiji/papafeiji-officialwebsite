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

REMOTE_DIR="/var/www/papafeiji-officialwebsite"
DOMAIN="papafeiji.cn"
EXPECTED_IP="47.98.121.243"
SSL_EMAIL="admin@papafeiji.cn"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 -o LogLevel=ERROR"

# ═══════════════════════════════════════════
# 日志与工具函数
# ═══════════════════════════════════════════
START_TIME=$(date +%s)

log_step()   { echo ""; echo "=== $1 ==="; }
log_info()   { echo "[INFO] $1"; }
log_warn()   { echo "[WARN] $1" >&2; }
log_error()  { echo "[ERROR] $1" >&2; }
log_elapsed(){ echo "⏱ 耗时: ${1}s"; }

run_remote() {
  sshpass -p "${PASSWORD}" ssh ${SSH_OPTS} "${SERVER}" "$@"
}

is_first_deploy() {
  run_remote "test -f ${REMOTE_DIR}/index.html" >/dev/null 2>&1 && return 1 || return 0
}

# ═══════════════════════════════════════════
# 本地环境检查
# ═══════════════════════════════════════════
install_local_pkg() {
  local pkg="$1"
  log_info "正在安装 ${pkg}..."
  if [ "$(id -u)" -eq 0 ]; then
    command -v apt-get >/dev/null 2>&1 && { apt-get update -qq && apt-get install -y "${pkg}"; return; }
    command -v yum >/dev/null 2>&1 && { yum install -y "${pkg}"; return; }
  else
    command -v apt-get >/dev/null 2>&1 && { sudo apt-get update -qq && sudo apt-get install -y "${pkg}"; return; }
    command -v yum >/dev/null 2>&1 && { sudo yum install -y "${pkg}"; return; }
  fi
  return 1
}

check_local_env() {
  log_step "检查本地环境"
  command -v node >/dev/null 2>&1   || { log_error "本地未安装 Node.js"; exit 1; }
  command -v npm >/dev/null 2>&1    || { log_error "本地未安装 npm"; exit 1; }
  command -v sshpass >/dev/null 2>&1 || install_local_pkg sshpass || { log_error "无法安装 sshpass"; exit 1; }
  command -v rsync >/dev/null 2>&1   || install_local_pkg rsync   || { log_error "无法安装 rsync"; exit 1; }
  log_info "本地环境就绪"
}

# ═══════════════════════════════════════════
# Git 状态检查
# ═══════════════════════════════════════════
check_git() {
  log_step "检查 Git 状态"
  cd "$LOCAL_DIR"
  if [ -n "$(git status --porcelain)" ]; then
    log_warn "存在未提交的变更，将一起部署"
  fi
  local branch=$(git branch --show-current)
  local ahead=$(git rev-list --count "origin/${branch}..${branch}" 2>/dev/null || echo 0)
  if [ "$ahead" -gt 0 ]; then
    log_warn "本地领先 origin/${branch} ${ahead} 个提交，将一起部署"
  fi
}

# ═══════════════════════════════════════════
# 前置检查
# ═══════════════════════════════════════════
check_dns() {
  log_step "检查域名解析"
  if ! getent hosts "${DOMAIN}" 2>/dev/null | grep -q "${EXPECTED_IP}"; then
    if command -v dig >/dev/null 2>&1; then
      if ! dig +short "${DOMAIN}" | grep -q "${EXPECTED_IP}"; then
        log_error "${DOMAIN} 未解析到 ${EXPECTED_IP}"; exit 1
      fi
    elif command -v nslookup >/dev/null 2>&1; then
      if ! nslookup "${DOMAIN}" 2>/dev/null | grep -q "${EXPECTED_IP}"; then
        log_error "${DOMAIN} 未解析到 ${EXPECTED_IP}"; exit 1
      fi
    else
      log_error "无法验证 DNS，请确认 ${DOMAIN} 指向 ${EXPECTED_IP}"; exit 1
    fi
  fi
  log_info "${DOMAIN} → ${EXPECTED_IP}"
}

check_ssh() {
  log_step "检查服务器 SSH 连通性"
  run_remote "echo ok" >/dev/null 2>&1 || { log_error "SSH 连接失败"; exit 1; }
  log_info "SSH 连接正常"
}

# ═══════════════════════════════════════════
# 智能构建：仅在源码变更时执行
# ═══════════════════════════════════════════
build_main() {
  log_step "本地构建官网"
  cd "$LOCAL_DIR"

  # 检查依赖是否需要更新
  if [ "package.json" -nt "node_modules/.package-lock.json" ] 2>/dev/null; then
    log_info "依赖有变更，npm install..."
    npm install
  elif [ ! -d "node_modules" ]; then
    log_info "首次安装依赖..."
    npm install
  else
    log_info "依赖已是最新，跳过 npm install"
  fi

  npm run build

  if [ ! -d "${LOCAL_DIR}/out" ]; then
    log_error "构建后未找到 out 目录"; exit 1
  fi
}

# ═══════════════════════════════════════════
# Nginx 管理（仅首次部署或 nginx 未运行时操作）
# ═══════════════════════════════════════════
ensure_nginx() {
  log_step "确保 nginx 已安装并运行"

  local nginx_ok
  nginx_ok=$(run_remote "command -v nginx >/dev/null 2>&1 && systemctl is-active nginx 2>/dev/null")

  if [ -z "${nginx_ok}" ]; then
    log_info "nginx 未安装，正在安装..."
    run_remote "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq && apt-get install -y nginx && systemctl enable --now nginx"
  elif [ "${nginx_ok}" != "active" ]; then
    log_info "nginx 未运行，正在启动..."
    run_remote "systemctl start nginx"
  else
    log_info "nginx 运行中"
  fi
}

sync_main() {
  log_step "同步构建产物到服务器"
  local sync_start=$(date +%s)
  sshpass -p "${PASSWORD}" rsync -av --delete -e "ssh ${SSH_OPTS}" "${LOCAL_DIR}/out/" "${SERVER}:${REMOTE_DIR}/"
  log_info "产物已同步到 ${REMOTE_DIR}"
  log_elapsed $(($(date +%s) - sync_start))
}

# ═══════════════════════════════════════════
# Nginx 配置（仅首次部署写入，更新模式跳过）
# ═══════════════════════════════════════════
ensure_nginx_config() {
  log_step "检查/创建 nginx 配置"

  if [ "${first_deploy}" != "true" ]; then
    log_info "更新部署，跳过 nginx 配置重写"
    return
  fi

  log_info "首次部署，写入 nginx 配置..."

  # 先写 HTTP 配置
  run_remote "cat > /etc/nginx/sites-available/papafeiji-officialwebsite << 'NGINX_EOF'
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
ln -sf /etc/nginx/sites-available/papafeiji-officialwebsite /etc/nginx/sites-enabled/papafeiji-officialwebsite
nginx -t && systemctl reload nginx"
}

ensure_ssl_config() {
  if [ "${first_deploy}" != "true" ]; then
    return
  fi
  log_info "写入 HTTPS 配置..."
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
        try_files \\\$uri \\\$uri/ =404;
    }
}
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\\\$host\\\$request_uri;
}
NGINX_EOF
ln -sf /etc/nginx/sites-available/papafeiji-officialwebsite /etc/nginx/sites-enabled/papafeiji-officialwebsite
nginx -t && systemctl reload nginx"
}

# ═══════════════════════════════════════════
# SSL 证书管理（仅首次部署）
# ═══════════════════════════════════════════
ensure_ssl() {
  if [ "${first_deploy}" != "true" ]; then
    log_info "非首次部署，跳过 SSL 证书申请"
    return
  fi
  log_step "申请/部署 SSL 证书"

  run_remote "export DEBIAN_FRONTEND=noninteractive
    if ! command -v certbot >/dev/null 2>&1; then
      apt-get update -qq && apt-get install -y certbot python3-certbot-nginx
    fi"

  log_info "首次申请 SSL 证书..."
  run_remote "certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${SSL_EMAIL} --redirect || true"
  run_remote "systemctl enable certbot.timer 2>/dev/null || true
    systemctl start certbot.timer 2>/dev/null || true
    nginx -t && systemctl reload nginx"
}

# ═══════════════════════════════════════════
# 访问验证
# ═══════════════════════════════════════════
verify_access() {
  log_step "验证访问"
  local code

  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${DOMAIN}/" || echo "000")
  [ "${code}" = "200" ] && log_info "✓ https://${DOMAIN}/" || log_warn "✗ https://${DOMAIN}/ → ${code}"

  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${DOMAIN}/tutorial/" || echo "000")
  [ "${code}" = "200" ] && log_info "✓ https://${DOMAIN}/tutorial/" || log_warn "✗ https://${DOMAIN}/tutorial/ → ${code}"
}

# ═══════════════════════════════════════════
# 主流程
# ═══════════════════════════════════════════
main() {
  first_deploy=false
  is_first_deploy && { first_deploy=true; log_info "🔵 首次部署"; } || log_info "🟢 更新部署"

  check_local_env
  check_git
  check_dns
  check_ssh
  build_main
  ensure_nginx
  sync_main
  ensure_nginx_config
  ensure_ssl
  ensure_ssl_config
  verify_access

  echo ""
  echo "=== 部署完成 ==="
  echo "官网: https://${DOMAIN}"
  echo "教程: https://${DOMAIN}/tutorial/"
  log_elapsed $(($(date +%s) - START_TIME))
}

main "$@"
