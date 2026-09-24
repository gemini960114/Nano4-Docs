#!/usr/bin/env bash
# ==============================================================================
# install_vscode_extensions.sh - 一鍵安裝遠端 Python、Jupyter 與 AI Agent 擴充套件
# 用途：用 Antigravity（或 VS Code）Remote-SSH 連進 Nano4 後，在整合終端機中批次安裝套件
# ==============================================================================
set -euo pipefail

echo "========================================================"
echo "🚀 正在檢查遠端 CLI (antigravity-ide / code)..."
echo "========================================================"

# Antigravity 的遠端 CLI 叫 antigravity-ide；VS Code 叫 code
CODE_CMD=""
for c in antigravity-ide code; do
    # 存完整路徑，否則後面的 [ -x ] 會把裸指令名稱當成目前目錄下的檔案
    if command -v "$c" &>/dev/null; then CODE_CMD="$(command -v "$c")"; break; fi
done
if [ -z "${CODE_CMD}" ]; then
    # 不在 PATH 時，到兩種伺服器的安裝目錄尋找 remote-cli
    CODE_CMD=$(find "${HOME}/.antigravity-ide-server" "${HOME}/.vscode-server" \
        -path "*remote-cli/*" \( -name antigravity-ide -o -name code \) -type f 2>/dev/null | head -n 1 || true)
fi
if [ -z "${CODE_CMD}" ] || [ ! -x "${CODE_CMD}" ]; then
    echo "⚠️ 提示：找不到 Antigravity / VS Code 的遠端 CLI。"
    echo "💡 請在『已用 Remote-SSH 連上 Nano4 的 Antigravity 或 VS Code』整合式終端機中執行本腳本；"
    echo "   或者直接在左側 Extensions 面板搜尋套件並點選 Install in SSH。"
    exit 1
fi

echo "使用遠端 CLI: ${CODE_CMD}"
echo "========================================================"

EXTENSIONS=(
    # --- Python & Jupyter 互動式運算套件 ---
    "ms-toolsai.jupyter"                  # Jupyter 核心引擎
    "ms-toolsai.jupyter-keymap"           # Jupyter 原生快捷鍵習慣
    "ms-toolsai.jupyter-renderers"        # 互動式圖表渲染器
    "ms-python.python"                    # Python 語法高亮與環境識別
    "ms-python.debugpy"                   # Python 斷點除錯器

    # --- AI Agent（Antigravity 另有內建 Agent，不需安裝）---
    "anthropic.claude-code"               # Claude Code（需 Claude 帳號）
    "openai.chatgpt"                      # Codex（需 ChatGPT 帳號）
)

for ext in "${EXTENSIONS[@]}"; do
    echo "==> 正在遠端安裝套件: ${ext} ..."
    "${CODE_CMD}" --install-extension "${ext}" --force || {
        echo "⚠️ 安裝 ${ext} 失敗或暫時無法存取市集，繼續安裝下一個..."
    }
done

echo "========================================================"
echo "✅ 遠端擴充套件安裝流程完成！"
echo "目前遠端已安裝的套件清單:"
"${CODE_CMD}" --list-extensions
echo "========================================================"
