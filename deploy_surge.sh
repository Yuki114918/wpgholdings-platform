#!/usr/bin/env bash
# ============================================================
# 一键部署脚本：同步 git repo 源文件 → surge-dist / hr-report-dist → 部署两域名 → 验证
# 用途：避免"重建 dist 漏文件"导致报告页/数据 404。每次改完内容跑一次即可。
# 用法：bash deploy_surge.sh
# ============================================================
set -e

REPO="C:/Users/Yuki/WorkBuddy/wpgholdings-platform"
WORK="C:/Users/Yuki/WorkBuddy/2026-08-06-09-04-19"
SURGE_DIST="$WORK/surge-dist"
HR_DIST="$WORK/hr-report-dist"
SURGE_BIN="C:/Users/Yuki/.workbuddy/binaries/node/workspace/node_modules/.bin/surge"
export SURGE_LOGIN=token
export SURGE_TOKEN=cc4c6429fbfdc65bd985d123e11d7ecd

echo "==> [1/5] 清理并重建 dist 目录"
# 用覆盖式同步保证“不漏文件”：rm 被沙箱 safe-delete 拦截时降级为容错，依赖下方 cp 全量覆盖
rm -rf "$SURGE_DIST" "$HR_DIST" 2>/dev/null || true
mkdir -p "$SURGE_DIST/icons" "$HR_DIST/icons"

echo "==> [2/5] 同步工作台文件到 surge-dist (wpgholdings-todo)"
cp "$REPO/index.html" "$REPO/work-platform.html" "$REPO/report.html" "$REPO/landing.html" "$SURGE_DIST/"
cp "$REPO/"*.enc "$SURGE_DIST/"
cp "$REPO/chart.umd.min.js" "$SURGE_DIST/"
cp "$REPO/manifest.json" "$REPO/sw.js" "$SURGE_DIST/"
cp "$REPO/icon-192.png" "$REPO/icon-512.png" "$SURGE_DIST/icons/"
cp -r "$REPO/images" "$SURGE_DIST/" 2>/dev/null || true

echo "==> [3/5] 同步独立报告到 hr-report-dist (hr-insight-report)"
cp "$REPO/standalone-report.html" "$HR_DIST/index.html"
cp "$REPO/"*.enc "$HR_DIST/"
cp "$REPO/chart.umd.min.js" "$HR_DIST/"
cp "$REPO/manifest.json" "$REPO/sw.js" "$HR_DIST/"
cp "$REPO/icon-192.png" "$REPO/icon-512.png" "$HR_DIST/icons/"

echo "==> [4/5] 部署两个域名"
"$SURGE_BIN" deploy "$SURGE_DIST" --domain wpgholdings-todo.surge.sh
"$SURGE_BIN" deploy "$HR_DIST" --domain hr-insight-report.surge.sh

echo "==> [5/5] 验证关键 URL (期望全 200)"
sleep 3
for url in \
  "https://wpgholdings-todo.surge.sh/" \
  "https://wpgholdings-todo.surge.sh/report.html" \
  "https://wpgholdings-todo.surge.sh/report-comparison-v2.html.enc" \
  "https://wpgholdings-todo.surge.sh/report-content-v2.html.enc" \
  "https://wpgholdings-todo.surge.sh/report-hr-trends-v2.html.enc" \
  "https://wpgholdings-todo.surge.sh/chart.umd.min.js" \
  "https://hr-insight-report.surge.sh/" \
  "https://hr-insight-report.surge.sh/report-content-v2.html.enc" \
  "https://hr-insight-report.surge.sh/report-comparison-v2.html.enc" \
  "https://hr-insight-report.surge.sh/chart.umd.min.js" \
  "https://yuki114918.github.io/wpgholdings-platform/report.html" ; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "  $code  $url"
done

echo "==> 部署完成。HR 数据人数请另跑 build/verify_live.js 核对。"
