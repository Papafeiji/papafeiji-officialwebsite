# AGENTS.md

## 每次修改后必须执行

1. `git add -A && git commit -m "<描述>"`
2. `git push`
3. `bash deploy.sh` 验证部署成功

## 环境变量

部署前请设置：

```bash
export CLOUDFLARE_API_TOKEN="你的Cloudflare API Token"
export CLOUDFLARE_ACCOUNT_ID="你的Cloudflare Account ID"
```

Token 需要以下权限：`#worker:edit`、`#dns_records:edit`、`#zone:edit`
