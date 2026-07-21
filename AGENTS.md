# AGENTS.md

## 每次修改后必须执行

1. `git add -A && git commit -m "<描述>"`
2. `git push`
3. `bash deploy.sh` 验证部署成功

## 环境变量

部署所需的环境变量已配置在 `/root/.env.papafeiji`。执行部署时直接加载该文件即可，无需再询问或手动设置：

```bash
set -a && source /root/.env.papafeiji && set +a && bash deploy.sh
```

Token 需要以下权限：`#worker:edit`
