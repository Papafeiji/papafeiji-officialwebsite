#!/bin/bash
set -e

START_TIME=$(date +%s)

log_step()   { echo ""; echo "=== $1 ==="; }
log_info()   { echo "[INFO] $1"; }
log_error()  { echo "[ERROR] $1" >&2; }
log_elapsed(){ echo "⏱ 耗时: ${1}s"; }

LOCAL_DIR="$(dirname "$(readlink -f "$0")")"

check_env() {
  log_step "检查环境变量"
  : "${CLOUDFLARE_API_TOKEN:?请设置 CLOUDFLARE_API_TOKEN}"
  : "${CLOUDFLARE_ACCOUNT_ID:?请设置 CLOUDFLARE_ACCOUNT_ID}"
  log_info "CLOUDFLARE_ACCOUNT_ID = ${CLOUDFLARE_ACCOUNT_ID}"
  command -v node >/dev/null 2>&1   || { log_error "未安装 Node.js"; exit 1; }
  command -v npx  >/dev/null 2>&1   || { log_error "未安装 npx"; exit 1; }
}

install_deps() {
  log_step "安装依赖"
  cd "$LOCAL_DIR"
  if [ "package.json" -nt "node_modules/.package-lock.json" ] 2>/dev/null; then
    npm install
  elif [ ! -d "node_modules" ]; then
    npm install
  else
    log_info "依赖已是最新"
  fi
}

build_site() {
  log_step "构建静态网站"
  cd "$LOCAL_DIR"
  npm run build
  if [ ! -d "out" ]; then
    log_error "构建后未找到 out 目录"; exit 1
  fi
}

deploy() {
  log_step "部署到 Cloudflare Workers"
  cd "$LOCAL_DIR"
  npx wrangler deploy
}

bind_domain() {
  log_step "绑定自定义域名"
  local domain="pathmemos.com"
  local service="papafeiji-official-website"

  local resp
  resp=$(curl -s -X POST \
    "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/workers/domains" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"service\":\"${service}\",\"environment\":\"production\",\"hostname\":\"${domain}\"}")

  if echo "$resp" | python3 -c "import sys,json; d=json.load(sys.stdin); exit(0 if d.get('success') else 1)" 2>/dev/null; then
    log_info "✔ 域名 ${domain} 已绑定到 ${service}"
  else
    local msg
    msg=$(echo "$resp" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('errors',[{}])[0].get('message',''))" 2>/dev/null || echo "未知错误")
    if echo "$msg" | grep -qi "already exists\|already taken"; then
      log_info "域名 ${domain} 已绑定，跳过"
    elif echo "$msg" | grep -qi "not allowed\|permission"; then
      log_warn "Token 权限不足，跳过域名绑定（需在 Cloudflare Dashboard 手动配置）"
      log_info "确保 DNS 记录 pathmemos.com → AAAA 100:: (已代理) 已存在"
    else
      log_warn "绑定失败 (非致命): ${msg}"
    fi
  fi
}

verify() {
  log_step "验证部署"
  local domain="pathmemos.com"
  for path in "/" "/en/"; do
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${domain}${path}" || echo "000")
    if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]; then
      log_info "✔ https://${domain}${path} → ${code}"
    else
      log_error "✗ https://${domain}${path} → ${code}"
    fi
  done
}

main() {
  check_env
  install_deps
  build_site
  deploy
  bind_domain
  verify
  echo ""
  log_elapsed $(($(date +%s) - START_TIME))
}

main "$@"
