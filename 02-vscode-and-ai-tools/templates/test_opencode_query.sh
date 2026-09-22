#!/usr/bin/env bash
# ==============================================================================
# test_opencode_query.sh - 測試 OpenCode 模型清單與 CLI 連線能力
# ==============================================================================
set -euo pipefail

OPENCODE_BIN="${HOME}/.opencode/bin/opencode"

if [ ! -x "${OPENCODE_BIN}" ]; then
    if command -v opencode &>/dev/null; then
        OPENCODE_BIN="$(command -v opencode)"
    else
        echo "❌ 找不到 opencode 執行檔，請先執行 install_ai_cli.sh！"
        exit 1
    fi
fi

echo "========================================================"
echo "🤖 [測試 1] 查看目前載入的所有 Provider 與模型清單:"
echo "========================================================"
"${OPENCODE_BIN}" models | grep -E "medusa|local|google" || "${OPENCODE_BIN}" models

echo "========================================================"
echo "💬 [測試 2] 透過 OpenCode 向預設模型提問:"
echo "指令: opencode run \"請用一句話介紹國網中心超級電腦\""
echo "========================================================"
"${OPENCODE_BIN}" run "請用一句話介紹國網中心超級電腦" || {
    echo "⚠️ 查詢失敗，請檢查 API Key 是否有效，或內網連線是否通暢。"
}
