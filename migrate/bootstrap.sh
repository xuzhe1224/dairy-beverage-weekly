#!/bin/bash
set -e

# ============================================================
# dairy-beverage-weekly 项目 - 新机器一键环境准备脚本
# ============================================================
# 用法：
#   EDGEONE_PAGES_API_TOKEN="你的token" bash bootstrap.sh
#
# 功能：
#   1. Clone 源码仓库到项目 workspace
#   2. 安装 EdgeOne CLI 到 managed node workspace
#   3. 注入环境变量到 ~/.zshrc
#   4. 测试部署链路
# ============================================================

# --- 配置 ---
WORKSPACE="/Users/$(whoami)/WorkBuddy/2026-06-07-23-56-52"
REPO_URL="https://github.com/xuzhe1224/dairy-beverage-weekly.git"
NODE_VERSION="22.22.2"
NODE_BIN="/Users/$(whoami)/.workbuddy/binaries/node/versions/$NODE_VERSION/bin/node"
NPM_BIN="/Users/$(whoami)/.workbuddy/binaries/node/versions/$NODE_VERSION/bin/npm"
NODE_WORKSPACE="/Users/$(whoami)/.workbuddy/binaries/node/workspace"
EDGEONE_CLI="$NODE_WORKSPACE/node_modules/edgeone/edgeone-bin/edgeone.js"
TOKEN="${EDGEONE_PAGES_API_TOKEN:-}"

# --- Token 检查 ---
if [ -z "$TOKEN" ]; then
  echo "❌ 未检测到 EDGEONE_PAGES_API_TOKEN 环境变量"
  echo '   用法: EDGEONE_PAGES_API_TOKEN="你的token" bash bootstrap.sh'
  exit 1
fi
echo "✅ EdgeOne Token 已检测到"

# --- Step 1: Clone 源码 ---
echo ""
echo "📦 Step 1/4: Clone 源码仓库..."
TMP_DIR="/tmp/dbw-bootstrap-$$"
rm -rf "$TMP_DIR"
git clone "$REPO_URL" "$TMP_DIR" 2>&1 | tail -3

# 创建 workspace 并复制文件
mkdir -p "$WORKSPACE"
# 复制 eo-deploy（部署源+历史报告）
cp -R "$TMP_DIR/eo-deploy" "$WORKSPACE/"
# 复制 migrate 脚本
cp -R "$TMP_DIR/migrate" "$WORKSPACE/"
# 复制 .workbuddy/automations（执行记录）
mkdir -p "$WORKSPACE/.workbuddy/automations"
cp -R "$TMP_DIR/.workbuddy/automations/"* "$WORKSPACE/.workbuddy/automations/" 2>/dev/null || true
# 复制 .workbuddy/memory（daily logs，不含 MEMORY.md）
mkdir -p "$WORKSPACE/.workbuddy/memory"
cp -R "$TMP_DIR/.workbuddy/memory/"* "$WORKSPACE/.workbuddy/memory/" 2>/dev/null || true
# 复制 .gitignore 和 README
cp "$TMP_DIR/.gitignore" "$WORKSPACE/" 2>/dev/null || true
cp "$TMP_DIR/README.md" "$WORKSPACE/" 2>/dev/null || true

rm -rf "$TMP_DIR"
echo "   ✅ 源码已复制到 $WORKSPACE"

# --- Step 2: 安装 EdgeOne CLI ---
echo ""
echo "📦 Step 2/4: 安装 EdgeOne CLI..."
if [ ! -f "$NODE_BIN" ]; then
  echo "   ⚠️  Managed node $NODE_VERSION 未找到"
  echo "   请先在 WorkBuddy 里运行一次任意任务让它自动安装 managed node"
  echo "   安装后重新运行: EDGEONE_PAGES_API_TOKEN=\"$TOKEN\" bash $WORKSPACE/migrate/bootstrap.sh"
  exit 1
fi
echo "   ✅ Managed node $NODE_VERSION 已就绪"

mkdir -p "$NODE_WORKSPACE"
cd "$NODE_WORKSPACE"
if [ -f "$EDGEONE_CLI" ]; then
  echo "   ✅ EdgeOne CLI 已安装"
else
  echo "   正在安装 edgeone npm 包..."
  "$NPM_BIN" install edgeone 2>&1 | tail -3
  echo "   ✅ EdgeOne CLI 安装完成"
fi

# --- Step 3: 注入环境变量 ---
echo ""
echo "📦 Step 3/4: 注入环境变量到 ~/.zshrc..."
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

if grep -q "EDGEONE_PAGES_API_TOKEN" "$ZSHRC" 2>/dev/null; then
  echo "   ✅ 环境变量已存在（~/.zshrc 中已配置）"
else
  echo "" >> "$ZSHRC"
  echo "# === dairy-beverage-weekly 部署用 ===" >> "$ZSHRC"
  echo "export EDGEONE_PAGES_API_TOKEN=\"$TOKEN\"" >> "$ZSHRC"
  echo "export NODE_TLS_REJECT_UNAUTHORIZED=0" >> "$ZSHRC"
  echo "   ✅ 环境变量已写入 ~/.zshrc"
fi

# --- Step 4: 测试部署 ---
echo ""
echo "📦 Step 4/4: 测试部署链路..."
cd "$WORKSPACE/eo-deploy"
echo "   正在部署到 EdgeOne（项目: dairy-beverage-weekly-v2）..."
DEPLOY_OUTPUT=$(NODE_TLS_REJECT_UNAUTHORIZED=0 \
  EDGEONE_PAGES_API_TOKEN="$TOKEN" \
  "$NODE_BIN" "$EDGEONE_CLI" \
  makers deploy . -n dairy-beverage-weekly-v2 -e production -a global 2>&1) || true

echo "$DEPLOY_OUTPUT" | tail -8

if echo "$DEPLOY_OUTPUT" | grep -q "EDGEONE_DEPLOY_URL"; then
  echo "   ✅ 部署成功！"
  echo "$DEPLOY_OUTPUT" | grep "EDGEONE_DEPLOY_URL"
else
  echo "   ⚠️  部署可能失败，请检查上方日志"
  echo "   常见原因：代理设置、网络问题、Token 过期"
fi

# --- 完成 ---
echo ""
echo "=============================================="
echo "✅ 环境准备完成！"
echo ""
echo "📁 项目路径: $WORKSPACE"
echo "🌐 访问地址: https://dairy-beverage-weekly.rftlife.com"
echo "🔗 EdgeOne URL: https://dairy-beverage-weekly-v2-nipfitrn.edgeone.cool"
echo ""
echo "📋 下一步：在 WorkBuddy 会话里粘贴 SETUP_PROMPT.md 的内容"
echo "   来创建每周五 17:00 的自动化任务"
echo "=============================================="
