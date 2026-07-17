export const translations = {
  zh: {
    // Navbar
    "nav.features": "功能特性",
    "nav.quickstart": "快速开始",
    "nav.integrations": "接入平台",
    "nav.opensource": "开源",
    "nav.tutorial": "教程",
    "nav.github": "GitHub",
    "nav.home": "首页",
    "site.name": "爬爬记忆助手",
    "site.tagline": "家庭私密时光记录助手",
    "site.copyright": "Copyright © 杭州陈乐乐科技有限公司 浙 ICP 备 2024085343号-2",

    // Hero
    "hero.badge": "爬爬记忆助手 v2.0",
    "hero.title.part1": "记录全家时光，",
    "hero.title.part2": "留存温暖回忆",
    "hero.subtitle": "一款主打家庭场景的私密时光记录工具。依托微信小程序，结合 AI 能力自动留存日记、照片、地理位置。支持 SaaS 云端和私有化部署，数据完全自主可控。",
    "hero.cta.deploy": "开始部署",
    "hero.cta.github": "在 GitHub 上查看",
    "hero.scrollHint": "向下滚动",

    // Problem
    "problem.badge": "核心痛点",
    "problem.title.1": "家庭回忆",
    "problem.title.2": "为何总是",
    "problem.title.3": "零散流失",
    "problem.title.4": "？",
    "problem.subtitle": "生活点滴随时间悄然流逝，照片散落各处，行程无处归档，家人间的温暖回忆缺乏一个系统化的私密记录空间。",
    "problem.card1.title": "数据隐私难保障",
    "problem.card1.desc": "家庭照片、行程记录存储在三方云端，隐私无法自主掌控，敏感数据有泄露风险。",
    "problem.card2.title": "家庭回忆难留存",
    "problem.card2.desc": "去过哪里、吃过什么、家人在一起的时光，缺乏系统工具长期留存回顾。",
    "problem.card3.title": "记录方式太繁琐",
    "problem.card3.desc": "手动记日记费时费力难坚持，照片分散在各 App 中，无法自动关联时间与地点。",

    // Solution
    "solution.badge": "解决方案",
    "solution.title.part1": "全家人的",
    "solution.title.part2": "私密回忆库",
    "solution.subtitle": "依托微信小程序，融合 AI 能力和开源私有化部署，打造一个安全、便捷、持久化的家庭记忆中枢。数据存储在你自己的服务器上，回忆只属于你和家人。",
    "solution.aiApps": "数据来源",
    "solution.memoryHub": "爬爬记忆助手",
    "solution.memoryHub.subtitle": "家庭记忆中枢",
    "solution.mcp": "MCP 协议接入",
    "solution.apiKey": "API Key 接入",
    "solution.autoTrack": "自动轨迹同步",
    "solution.dataSources": "使用渠道",
    "solution.ds.location": "地理位置轨迹",
    "solution.ds.diary": "日记与备忘",
    "solution.ds.family": "家庭共享记忆",
    "solution.ds.photos": "微信小程序 · 服务号",

    // Features
    "features.badge": "核心功能",
    "features.title.1": "六大核心能力，",
    "features.title.2": "全面守护家庭回忆",
    "features.subtitle": "从全自动位置记录到 AI 智能对话、家庭共享，爬爬记忆助手为你的家庭提供完整的私密记忆管理方案",
    "features.f1.title": "全自动位置记录",
    "features.f1.desc": "微信小程序后台持续采集 GPS，智能识别停留点，自动生成附带精准地址的日记条目。全程无需手动操作，静默守护你的生活轨迹。",
    "features.f2.title": "AI 智能对话",
    "features.f2.desc": "内置 AI 对话能力，支持微信小程序和服务号双端使用。AI 读取你的历史日记，可精准回答「上周三中午吃了什么」等生活查询。",
    "features.f3.title": "家庭共享日记",
    "features.f3.desc": "创建共享家庭，最多 6 名成员协同记录。首页时间线自动聚合全家日记，每位成员的记录实时同步，全家回忆一目了然。",
    "features.f4.title": "MCP 个人记忆库",
    "features.f4.desc": "部署完成后自动开放 MCP 接口，无缝对接 Cursor、Claude Desktop 等主流 AI 工具，将你的记忆同步为 AI 可感知的专属上下文。",
    "features.f5.title": "私有化部署",
    "features.f5.desc": "支持 Docker 一键部署至个人私有服务器，所有日记、照片、位置记录存储在本地磁盘，无第三方留存，彻底保障数据隐私。",
    "features.f6.title": "完全开源",
    "features.f6.desc": "MIT 协议开源，代码透明可审计。后端完整复刻 SaaS 版本全部功能，开源版随官方迭代自动同步更新，无需手动维护。",

    // HowItWorks
    "how.badge": "快速开始",
    "how.title.1": "三步开启",
    "how.title.2": "家庭记忆管理",
    "how.subtitle": "无需复杂配置，一行命令即可完成私有化部署，微信小程序开箱即用",
    "how.step1.title": "一键部署",
    "how.step1.desc": "一行命令完成后端部署，小程序设置页填写自定义后端地址与 API Key，即可将所有数据路由至个人服务器。支持 SQLite 和 PostgreSQL。",
    "how.step2.title": "自动记录",
    "how.step2.desc": "授权位置权限后，小程序在后台持续采集 GPS 信息。智能识别停留点（300 米范围 + 10 分钟），自动聚合生成日记，无需手动操作。",
    "how.step3.title": "连接 AI",
    "how.step3.desc": "在小程序内随时与 AI 对话，查询过往回忆。也可通过 MCP 协议或 API Key 对接 Cursor、Claude 等 AI 工具，实现全工具记忆互通。",
    "how.cmd.comment": "# 按提示选择 opensource 模式 + SQLite 数据库，5 分钟完成部署",

    // Integrations
    "integrations.badge": "接入平台",
    "integrations.title.1": "全平台",
    "integrations.title.2": "记忆互通",
    "integrations.subtitle": "微信小程序、服务号双端覆盖，MCP 协议与 API Key 对接主流 AI 工具",
    "integrations.note": "支持通过 <span class=\"text-brand-gold font-medium\">MCP 协议</span> 或 <span class=\"text-brand-gold font-medium\">API Key</span> 接入任意兼容的 AI 客户端，实现全工具记忆共享",

    // OpenSource
    "opensource.badge": "开源生态",
    "opensource.title.1": "完全开源，",
    "opensource.title.2": "自由定制",
    "opensource.subtitle": "MIT 协议开源，代码完全透明。你可以私有化部署、二次开发、甚至商业使用。Cloudflare Worker 仅做轻量中转，全程不存储任何用户数据。",
    "opensource.install": "一键安装",
    "opensource.ghBtn": "访问 GitHub 仓库",
    "opensource.docBtn": "阅读文档",
    "opensource.card1.title": "双模式",
    "opensource.card1.desc": "SaaS 商业运营 + 开源私有化部署，同一套代码满足不同场景",
    "opensource.card2.title": "双数据库",
    "opensource.card2.desc": "SQLite 零运维快速启动，PostgreSQL 生产级高并发支持",
    "opensource.card3.title": "MIT 协议",
    "opensource.card3.desc": "标准开源协议，可自由修改、分发、商用，无后顾之忧",

    // Footer
    "footer.tutorial": "教程",
    "footer.privacy": "隐私政策",

    // Tutorial pages
    "tutorial.list.title": "使用教程",
    "tutorial.list.subtitle": "了解爬爬记忆助手的各项功能",
    "tutorial.back": "返回教程列表",
    "tutorial.minRead": "分钟阅读",
    "tutorial.home": "首页",

    // 404
    "page404.message": "页面未找到 / Page not found",
    "page404.back": "返回首页",

    // Meta
    "meta.title": "爬爬记忆助手 · 家庭私密时光记录助手",
    "meta.desc": "爬爬记忆助手是一款开源的私密时光记录工具。依托微信小程序，结合 AI 能力自动留存日记、照片、地理位置。支持私有化部署，数据完全自主可控。",
    "meta.ogDesc": "开源的私密时光记录工具，依托微信小程序，结合 AI 能力自动留存日记、照片、地理位置。",
  },

  en: {
    "nav.features": "Features",
    "nav.quickstart": "Quick Start",
    "nav.integrations": "Integrations",
    "nav.opensource": "Open Source",
    "nav.tutorial": "Tutorial",
    "nav.github": "GitHub",
    "nav.home": "Home",
    "site.name": "PathMemos",
    "site.tagline": "Private Family Memory Keeper",
    "site.copyright": "Copyright © Hangzhou ChenLeLe Technology Co., Ltd.",

    "hero.badge": "PathMemos v2.0",
    "hero.title.part1": "Capture Family Moments,",
    "hero.title.part2": "Keep Warm Memories Alive",
    "hero.subtitle": "A private time recording tool designed for families. Powered by WeChat Mini Program and AI, automatically preserving diaries, photos, and location trails. Self-hosted or SaaS — your data, fully under your control.",
    "hero.cta.deploy": "Deploy Now",
    "hero.cta.github": "View on GitHub",
    "hero.scrollHint": "Scroll Down",

    "problem.badge": "Core Pain Points",
    "problem.title.1": "Family memories",
    "problem.title.2": "why do they always ",
    "problem.title.3": "slip away",
    "problem.title.4": "?",
    "problem.subtitle": "Life's moments quietly fade away. Photos are scattered across apps, journeys go unarchived, and there's no systematic private space for family memories.",
    "problem.card1.title": "Privacy Concerns",
    "problem.card1.desc": "Family photos and travel records stored on third-party clouds — you have no real control, and sensitive data is at risk.",
    "problem.card2.title": "Memories Fade Away",
    "problem.card2.desc": "Where you've been, what you've eaten, time spent with loved ones — no systematic tool to preserve and revisit them long-term.",
    "problem.card3.title": "Recording Is Too Tedious",
    "problem.card3.desc": "Manual journaling takes time and discipline. Photos are scattered across apps and can't automatically link to time and place.",

    "solution.badge": "Solution",
    "solution.title.part1": "Your Family's",
    "solution.title.part2": "Private Memory Vault",
    "solution.subtitle": "Built on WeChat Mini Program, powered by AI, with open-source self-hosting — a secure, effortless, and enduring family memory hub. Your data lives on your own server. Your memories belong only to you and your family.",
    "solution.aiApps": "Data Sources",
    "solution.memoryHub": "PathMemos",
    "solution.memoryHub.subtitle": "Family Memory Hub",
    "solution.mcp": "MCP Protocol",
    "solution.apiKey": "API Key Access",
    "solution.autoTrack": "Auto Track Sync",
    "solution.dataSources": "Access Channels",
    "solution.ds.location": "Location Trajectory",
    "solution.ds.diary": "Diary & Notes",
    "solution.ds.family": "Family Shared Memory",
    "solution.ds.photos": "Mini Program · Official Account",

    "features.badge": "Core Features",
    "features.title.1": "Six Core Capabilities,",
    "features.title.2": "Guard Your Family Memories",
    "features.subtitle": "From auto location tracking to AI conversation and family sharing, PathMemos provides a complete private memory management solution for your family.",
    "features.f1.title": "Auto Location Tracking",
    "features.f1.desc": "The Mini Program continuously collects GPS in the background, intelligently identifies stay points, and auto-generates diary entries with precise addresses — all hands-free, silently safeguarding your life trail.",
    "features.f2.title": "AI Smart Assistant",
    "features.f2.desc": "Built-in AI chat accessible from both Mini Program and WeChat Official Account. The AI reads your past diaries and can precisely answer queries like 'What did I have for lunch last Wednesday?'",
    "features.f3.title": "Family Diary Sharing",
    "features.f3.desc": "Create shared families with up to 6 members for collaborative journaling. The home timeline auto-aggregates everyone's diaries in real time — your entire family's memories in one view.",
    "features.f4.title": "MCP Personal Memory Store",
    "features.f4.desc": "After deployment, the MCP endpoint is automatically available. Seamlessly connect Cursor, Claude Desktop, and other AI tools — sync your memories as context your AI can understand.",
    "features.f5.title": "Self-Hosted Deployment",
    "features.f5.desc": "Deploy to your private server with a single Docker command. All diaries, photos, and location records are stored on local disk — no third-party retention, total data privacy guaranteed.",
    "features.f6.title": "Fully Open Source",
    "features.f6.desc": "MIT licensed open source with auditable code. The backend fully replicates all SaaS features. Open-source edition auto-syncs with official updates — no manual maintenance needed.",

    "how.badge": "Quick Start",
    "how.title.1": "Three Steps to",
    "how.title.2": "Family Memory Management",
    "how.subtitle": "No complex setup — deploy with a single command, use with WeChat Mini Program out of the box.",
    "how.step1.title": "One-Click Deploy",
    "how.step1.desc": "Deploy the backend with one command. Fill in your custom backend URL and API Key in the Mini Program settings — all data routes to your personal server. Supports SQLite and PostgreSQL.",
    "how.step2.title": "Auto Recording",
    "how.step2.desc": "After granting location permission, the Mini Program continuously collects GPS in the background, intelligently identifies stay points (300m range + 10 min), and auto-generates diary entries.",
    "how.step3.title": "Connect AI",
    "how.step3.desc": "Chat with AI anytime inside the Mini Program to query past memories. Or connect via MCP protocol / API Key to Cursor, Claude, and other AI tools for cross-tool memory sharing.",
    "how.cmd.comment": "# Follow the prompts to select opensource mode + SQLite, deploy in 5 minutes",

    "integrations.badge": "Supported Platforms",
    "integrations.title.1": "All Platforms,",
    "integrations.title.2": "One Memory",
    "integrations.subtitle": "WeChat Mini Program and Official Account, plus MCP and API Key integration for all major AI tools.",
    "integrations.note": "Supports any <span class=\"text-brand-gold font-medium\">MCP protocol</span> compatible or <span class=\"text-brand-gold font-medium\">API Key</span> accessible AI client for cross-tool memory sharing",

    "opensource.badge": "Open Source",
    "opensource.title.1": "Fully Open Source,",
    "opensource.title.2": "Free to Customize",
    "opensource.subtitle": "MIT licensed with fully transparent code. Self-host, customize, or use commercially. Cloudflare Worker only acts as a lightweight relay — no user data is ever stored.",
    "opensource.install": "One-Click Install",
    "opensource.ghBtn": "View GitHub Repository",
    "opensource.docBtn": "Read Documentation",
    "opensource.card1.title": "Dual Mode",
    "opensource.card1.desc": "SaaS commercial operation + open source self-hosted deployment, one codebase for all scenarios.",
    "opensource.card2.title": "Dual Database",
    "opensource.card2.desc": "SQLite for zero-ops quick start, PostgreSQL for production-grade high concurrency.",
    "opensource.card3.title": "MIT License",
    "opensource.card3.desc": "Standard open source license. Free to modify, distribute, and use commercially with no strings attached.",

    "footer.tutorial": "Tutorial",
    "footer.privacy": "Privacy Policy",

    "tutorial.list.title": "Tutorials",
    "tutorial.list.subtitle": "Learn how to use PathMemos",
    "tutorial.back": "Back to Tutorials",
    "tutorial.minRead": "min read",
    "tutorial.home": "Home",

    // 404
    "page404.message": "Page not found / 页面未找到",
    "page404.back": "Back to Home",

    "meta.title": "PathMemos · Private Family Memory Keeper",
    "meta.desc": "PathMemos is an open-source private time recording tool. Powered by WeChat Mini Program and AI, it automatically preserves diaries, photos, and location trails. Self-hosted for total data control.",
    "meta.ogDesc": "Open-source private time recording tool, powered by WeChat Mini Program and AI, preserving diaries, photos, and location trails.",
  },
} as const;

export type TranslationKey = keyof typeof translations.zh;
export type Lang = 'zh' | 'en';

export function t(lang: Lang, key: string): string {
  const result = (translations[lang] as Record<string, string>)[key];
  if (result !== undefined) return result;
  if (lang !== 'zh') {
    const fallback = (translations.zh as Record<string, string>)[key];
    if (fallback !== undefined) return fallback;
  }
  return key;
}

export function createT(lang: string) {
  return (key: string) => t(lang as Lang, key);
}
