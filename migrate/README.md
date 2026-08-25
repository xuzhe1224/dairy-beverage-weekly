# dairy-beverage-weekly 跨机器迁移指南

## 项目概述

乳制品饮料行业周报自动化项目，每周五 17:00 自动生成周报（月末加月报），部署到腾讯 EdgeOne Pages。

- **自定义域名**: https://dairy-beverage-weekly.rftlife.com
- **EdgeOne URL**: https://dairy-beverage-weekly-v2-nipfitrn.edgeone.cool
- **GitHub 仓库**: https://github.com/xuzhe1224/dairy-beverage-weekly
- **自动化 cron**: 每周五 17:00（FREQ=WEEKLY;BYDAY=FR;BYHOUR=17;BYMINUTE=0）
- **Expert**: GPTResearcherTeam
- **Connectors**: tencent-docs, tyc-mcp, ima-mcp, tdx-connector

## 迁移步骤（新机器上只需 2 步）

### 第 1 步：启动 WorkBuddy

在新机器（Mac mini）上打开 WorkBuddy，进入任意项目空间。

### 第 2 步：粘贴迁移指令

将 `SETUP_PROMPT.md` 的内容复制到 WorkBuddy 会话里发送（token 需替换为实际值）。

WorkBuddy 会自动完成：
1. 检查并安装 managed node 22.22.2
2. Clone 源码仓库
3. 安装 EdgeOne CLI
4. 注入环境变量到 ~/.zshrc
5. 测试部署链路
6. 创建每周五 17:00 的自动化任务

## 文件说明

| 文件 | 用途 |
|---|---|
| `bootstrap.sh` | 新机器一键环境准备脚本（clone、安装 CLI、注入 token、测试部署） |
| `AUTOMATION_PROMPT.md` | 自动化任务的完整 prompt（用于 automation_update 创建任务） |
| `SETUP_PROMPT.md` | 给新机器 WorkBuddy 会话粘贴的指令模板（token 用 `<EDGEONE_TOKEN>` 占位） |
| `README.md` | 本文件 |

## 关键配置

| 配置项 | 值 |
|---|---|
| EdgeOne 项目名 | dairy-beverage-weekly-v2 |
| EdgeOne 项目类型 | Upload（CLI 直接推送） |
| 自定义域名 | dairy-beverage-weekly.rftlife.com |
| EdgeOne 访问 URL | https://dairy-beverage-weekly-v2-nipfitrn.edgeone.cool |
| Node 版本 | 22.22.2（managed） |
| EdgeOne CLI 路径 | ~/.workbuddy/binaries/node/workspace/node_modules/edgeone/edgeone-bin/edgeone.js |
| 部署命令 | `makers deploy . -n dairy-beverage-weekly-v2 -e production -a global` |

## 注意事项

1. **NODE_TLS_REJECT_UNAUTHORIZED=0** 必须（macOS TLS 问题，已写入 ~/.zshrc）
2. **Managed node 22.22.2** 需要先在 WorkBuddy 里触发安装（SETUP_PROMPT.md 已包含此步骤）
3. **EdgeOne Token** 通过环境变量 `EDGEONE_PAGES_API_TOKEN` 传递，已写入 `~/.zshrc`
4. **用户名假设**：脚本使用 `$(whoami)` 动态获取用户名，但 automation 的 cwds 和 prompt 中的路径硬编码为 `/Users/xuzhe/...`。如果新机器用户名不是 `xuzhe`，需要手动修改 cwds 和 prompt 中的路径
5. **月末判断**：automation 会在每月最后一个周五同时生成周报+月报，其他周仅生成周报
6. **原机器**：迁移完成后，如需停止原机器的自动化，在原机器 WorkBuddy 里执行 `automation_update mode=update id=<原ID> status=PAUSED`
