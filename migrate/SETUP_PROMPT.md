# Mac mini 迁移 - WorkBuddy 会话指令

> **使用方法**：在新机器的 WorkBuddy 会话里，复制以下分隔线之间的全部内容，直接发送。
> WorkBuddy 会自动执行所有迁移步骤，无需你手动干预。

---

请帮我完成乳制品饮料行业周报项目的跨机器迁移。以下是完整指令，请逐步执行，全程自动化，不需要我手动干预。

## 第一步：检查并安装 Managed Node

检查 managed node 22.22.2 是否存在（路径 `/Users/$(whoami)/.workbuddy/binaries/node/versions/22.22.2/bin/node`）。
如果不存在，请用 install_binary 工具安装 node 22.22.2。

## 第二步：执行环境准备脚本

在终端执行以下命令（token 已填好）：

```bash
EDGEONE_PAGES_API_TOKEN="<EDGEONE_TOKEN>" bash /tmp/dbw-bootstrap.sh
```

如果 `/tmp/dbw-bootstrap.sh` 不存在，先执行以下命令下载并运行：

```bash
mkdir -p /tmp/dbw-setup && cd /tmp/dbw-setup && \
git clone https://github.com/xuzhe1224/dairy-beverage-weekly.git . && \
cp migrate/bootstrap.sh /tmp/dbw-bootstrap.sh && \
EDGEONE_PAGES_API_TOKEN="<EDGEONE_TOKEN>" bash /tmp/dbw-bootstrap.sh
```

这个脚本会自动完成：
1. Clone 源码仓库到 `/Users/$(whoami)/WorkBuddy/2026-06-07-23-56-52`
2. 安装 EdgeOne CLI 到 managed node workspace
3. 注入环境变量到 `~/.zshrc`（包括 EdgeOne Token 和 TLS 设置）
4. 测试部署到 EdgeOne（验证链路是否通畅）

## 第三步：创建自动化任务

环境准备完成后，使用 automation_update 工具创建以下自动化任务：

- **mode**: "create"
- **name**: "每周五17点生成乳制品饮料行业周报（月末加月报）"
- **cwds**: "/Users/$(whoami)/WorkBuddy/2026-06-07-23-56-52"
- **scheduleType**: "recurring"
- **rrule**: "FREQ=WEEKLY;BYDAY=FR;BYHOUR=17;BYMINUTE=0"
- **status**: "ACTIVE"
- **expertId**: "GPTResearcherTeam"
- **expertMarketplace**: "official"
- **connectorIds**: ["tencent-docs", "tyc-mcp", "ima-mcp", "tdx-connector"]

**prompt 字段**：从以下文件读取完整内容：
`/Users/$(whoami)/WorkBuddy/2026-06-07-23-56-52/migrate/AUTOMATION_PROMPT.md`

## 第四步：验证并报告

创建完成后，请告诉我：
1. 自动化任务 ID
2. 下次执行时间（应该是下个周五 17:00）
3. 部署测试是否成功
4. 网站是否可访问（https://dairy-beverage-weekly.rftlife.com）

如果任何步骤失败，请自动尝试修复或提示我需要做什么。

---
