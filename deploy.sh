#!/bin/bash
# 部署脚本：papafeiji-officialwebsite (官网) + papafeiji-news (news 博客站)
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
NEWS_DOMAIN="news.${DOMAIN}"
SERVER_NAME="${DOMAIN} ${NEWS_DOMAIN}"
EXPECTED_IP="47.98.121.243"
SSL_EMAIL="admin@papafeiji.cn"

# news 站点
NEWS_LOCAL_DIR="${LOCAL_DIR}/papafeiji-news"
NEWS_REMOTE_DIR="/var/www/papafeiji-news"

# FRP 服务端配置
FRPS_VERSION="0.69.1"
FRPS_BIND_PORT=7000
FRPS_TOKEN="jiuyueyun12724"
FRPS_LOCAL_TARBALL="${LOCAL_DIR}/frp_${FRPS_VERSION}_linux_amd64.tar.gz"

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
  if run_remote "test -f ${REMOTE_DIR}/index.html && test -f ${NEWS_REMOTE_DIR}/index.html" >/dev/null 2>&1; then
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

build_news() {
  log_step "本地构建 news 站点"
  if [ ! -d "${NEWS_LOCAL_DIR}" ]; then
    log_error "未找到 news 项目目录 ${NEWS_LOCAL_DIR}"
    exit 1
  fi

  cd "${NEWS_LOCAL_DIR}"
  npm install
  npm run build

  if [ ! -d "${NEWS_LOCAL_DIR}/dist" ]; then
    log_error "构建后未找到 ${NEWS_LOCAL_DIR}/dist 目录"
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

sync_news() {
  log_step "同步 news 构建产物到服务器"
  sshpass -p "${PASSWORD}" rsync -avz --delete \
    -e "ssh ${SSH_OPTS}" \
    "${NEWS_LOCAL_DIR}/dist/" "${SERVER}:${NEWS_REMOTE_DIR}/"
  log_info "news 产物已同步到 ${NEWS_REMOTE_DIR}"
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
    # 首次部署：写 HTTP 配置，后续由 certbot 负责 HTTPS
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
server {
    listen 80;
    server_name ${NEWS_DOMAIN};
    root ${NEWS_REMOTE_DIR};
    index index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX_EOF
ln -sf /etc/nginx/sites-available/papafeiji-officialwebsite /etc/nginx/sites-enabled/papafeiji-officialwebsite
nginx -t && systemctl reload nginx"
  else
    # 更新部署：直接写完整 HTTPS 配置，不调用 certbot
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
    listen 443 ssl;
    server_name ${NEWS_DOMAIN};
    root ${NEWS_REMOTE_DIR};
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
    server_name ${DOMAIN} ${NEWS_DOMAIN};
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
    certbot --nginx -d ${DOMAIN} -d ${NEWS_DOMAIN} --non-interactive --agree-tos -m ${SSL_EMAIL} --redirect
    systemctl enable certbot.timer 2>/dev/null || true
    systemctl start certbot.timer 2>/dev/null || true
    nginx -t && systemctl reload nginx
  "
}

# ═══════════════════════════════════════════
# FRP 服务端管理
# ═══════════════════════════════════════════
ensure_frp() {
  log_step "部署/更新 FRP 服务端 (frps)"

  local needs_restart=false
  local frps_arch
  case "$(uname -m)" in
    x86_64) frps_arch="amd64" ;;
    aarch64|arm64) frps_arch="arm64" ;;
    armv7l) frps_arch="arm" ;;
    *)
      log_warn "不支持的本地架构 $(uname -m)，跳过 frps 部署"
      return 0
      ;;
  esac

  local frps_tarball_name="frp_${FRPS_VERSION}_linux_${frps_arch}"
  local frps_tarball="${frps_tarball_name}.tar.gz"
  local frps_temp_dir
  frps_temp_dir=$(mktemp -d)

  # 准备本地安装包
  if [ -f "$FRPS_LOCAL_TARBALL" ]; then
    log_info "使用本地 frp 安装包：$FRPS_LOCAL_TARBALL"
    cp "$FRPS_LOCAL_TARBALL" "${frps_temp_dir}/${frps_tarball}"
  else
    log_info "本地未找到安装包，尝试从 GitHub 下载..."
    local frps_download_url="https://github.com/fatedier/frp/releases/download/v${FRPS_VERSION}/${frps_tarball}"
    if ! curl -L --connect-timeout 30 --max-time 300 -o "${frps_temp_dir}/${frps_tarball}" "$frps_download_url"; then
      log_error "下载 frp 安装包失败，跳过 frps 部署"
      rm -rf "$frps_temp_dir"
      return 0
    fi
  fi

  # 校验压缩包
  if ! tar -tzf "${frps_temp_dir}/${frps_tarball}" >/dev/null 2>&1; then
    log_error "frp 安装包损坏，跳过 frps 部署"
    rm -rf "$frps_temp_dir"
    return 0
  fi

  # 生成 frps.toml
  cat > "${frps_temp_dir}/frps.toml" << FRP_EOF
bindPort = ${FRPS_BIND_PORT}
auth.method = "token"
auth.token = "${FRPS_TOKEN}"
log.to = "/var/log/frps.log"
log.level = "info"
log.maxDays = 30
FRP_EOF

  # 生成 systemd service
  cat > "${frps_temp_dir}/frps.service" << FRP_EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.toml
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
FRP_EOF

  # 确保远程目录存在
  run_remote "mkdir -p /etc/frp"

  # 检查远程二进制版本
  local remote_version
  remote_version=$(run_remote "frps --version 2>/dev/null || echo none")

  if [ "${remote_version}" != "${FRPS_VERSION}" ]; then
    log_info "frps 二进制不存在或版本不匹配（远程：${remote_version}，期望：${FRPS_VERSION}），重新安装..."
    sshpass -p "${PASSWORD}" scp ${SSH_OPTS} "${frps_temp_dir}/${frps_tarball}" "${SERVER}:/tmp/${frps_tarball}"
    run_remote "
      set -e
      cd /tmp
      tar -xzf ${frps_tarball}
      cp ${frps_tarball_name}/frps /usr/local/bin/frps
      chmod +x /usr/local/bin/frps
      rm -rf /tmp/${frps_tarball_name} /tmp/${frps_tarball}
    "
    needs_restart=true
  else
    log_info "frps 二进制版本已匹配 ${FRPS_VERSION}"
  fi

  # 上传配置文件
  sshpass -p "${PASSWORD}" scp ${SSH_OPTS} "${frps_temp_dir}/frps.toml" "${SERVER}:/etc/frp/frps.toml.new"
  sshpass -p "${PASSWORD}" scp ${SSH_OPTS} "${frps_temp_dir}/frps.service" "${SERVER}:/etc/systemd/system/frps.service.new"

  # 通过 cmp 判断配置是否变更
  local config_changed
  config_changed=$(run_remote "
    if [ ! -f /etc/frp/frps.toml ] || [ ! -f /etc/frp/frps.toml.new ] || ! cmp -s /etc/frp/frps.toml /etc/frp/frps.toml.new; then
      echo yes
    else
      echo no
    fi
  ")

  local service_changed
  service_changed=$(run_remote "
    if [ ! -f /etc/systemd/system/frps.service ] || [ ! -f /etc/systemd/system/frps.service.new ] || ! cmp -s /etc/systemd/system/frps.service /etc/systemd/system/frps.service.new; then
      echo yes
    else
      echo no
    fi
  ")

  if [ "${config_changed}" = "yes" ] || [ "${service_changed}" = "yes" ]; then
    run_remote "
      set -e
      mv /etc/frp/frps.toml.new /etc/frp/frps.toml
      mv /etc/systemd/system/frps.service.new /etc/systemd/system/frps.service
    "
    needs_restart=true
    log_info "frps 配置已更新"
  else
    run_remote "
      rm -f /etc/frp/frps.toml.new /etc/systemd/system/frps.service.new
    "
    log_info "frps 配置未变更"
  fi

  run_remote "systemctl daemon-reload && systemctl enable frps"

  # 防火墙放行（仅在防火墙实际启用时操作）
  run_remote "
    if command -v ufw >/dev/null 2>&1 && ufw status | grep -q 'Status: active'; then
      ufw allow ${FRPS_BIND_PORT}/tcp || true
      ufw reload || true
    elif command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state >/dev/null 2>&1; then
      firewall-cmd --permanent --add-port=${FRPS_BIND_PORT}/tcp || true
      firewall-cmd --reload || true
    elif command -v iptables >/dev/null 2>&1; then
      iptables -I INPUT -p tcp --dport ${FRPS_BIND_PORT} -j ACCEPT || true
    fi
  "

  # 启动或重启服务
  if [ "${needs_restart}" = "true" ]; then
    log_info "重启 frps 服务..."
    run_remote "systemctl restart frps"
  else
    log_info "启动/保持 frps 服务..."
    run_remote "systemctl start frps"
  fi

  rm -rf "$frps_temp_dir"
  log_info "frps 部署完成：${SERVER}:${FRPS_BIND_PORT}"
}

# ═══════════════════════════════════════════
# 访问验证
# ═══════════════════════════════════════════
verify_access() {
  log_step "验证访问"
  local http_code news_http_code tutorial_code

  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${DOMAIN}/" || echo "000")
  if [ "${http_code}" = "200" ]; then
    log_info "验证成功：https://${DOMAIN}/ 返回 200"
  else
    log_warn "https://${DOMAIN}/ 验证请求返回 ${http_code}，请手动检查"
  fi

  news_http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${NEWS_DOMAIN}/" || echo "000")
  if [ "${news_http_code}" = "200" ]; then
    log_info "验证成功：https://${NEWS_DOMAIN}/ 返回 200"
  else
    log_warn "https://${NEWS_DOMAIN}/ 验证请求返回 ${news_http_code}，请手动检查"
  fi

  tutorial_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${NEWS_DOMAIN}/tutorial0/" || echo "000")
  if [ "${tutorial_code}" = "200" ]; then
    log_info "验证成功：https://${NEWS_DOMAIN}/tutorial0/ 返回 200"
  else
    log_warn "https://${NEWS_DOMAIN}/tutorial0/ 验证请求返回 ${tutorial_code}，请手动检查"
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
  build_news
  ensure_nginx
  sync_main
  sync_news
  ensure_nginx_config
  if [ "${first_deploy}" = "true" ]; then
    ensure_ssl
  fi
  ensure_frp
  verify_access

  echo ""
  echo "=== 部署完成 ==="
  echo "官网访问地址: https://${DOMAIN}"
  echo "news 访问地址: https://${NEWS_DOMAIN}"
  echo "证书覆盖域名: ${DOMAIN}, ${NEWS_DOMAIN}"
  echo "FRP 服务端: ${SERVER}:${FRPS_BIND_PORT}"
}

main "$@"
