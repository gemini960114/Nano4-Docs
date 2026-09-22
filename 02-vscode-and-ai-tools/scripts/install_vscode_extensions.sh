#!/usr/bin/env bash
# ==============================================================================
# install_vscode_extensions.sh - 一鍵安裝遠端 VS Code 核心開發與 AI 擴充套件
# 用途：當使用 VS Code Remote-SSH 連線進入 Nano4 後，在整合終端機中批次安裝套件
# ==============================================================================
set -euo pipefail

echo "========================================================"
echo "🚀 正在檢查遠端 VS Code CLI (code)..."
echo "========================================================"

if command -v code &>/dev/null; then
    CODE_CMD="code"
else
    # 嘗試在 ~/.vscode-server 中搜尋 remote-cli/code
    REMOTE_CODE=$(find "${HOME}/.vscode-server" -name "code" -type f 2>/dev/null | head -n 1 || true)
    if [ -n "${REMOTE_CODE}" ] && [ -x "${REMOTE_CODE}" ]; then
        CODE_CMD="${REMOTE_CODE}"
    else
        echo "⚠️ 提示：未在當前 PATH 找到 'code' 命令。"
        echo "💡 請確認您目前是在『本地 VS Code Remote-SSH』所開啟的整合式終端機中執行本腳本；"
        echo "   或者您可以直接在 VS Code 左側 Extensions 面板中搜尋並點擊安裝。"
        exit 1
    fi
fi

echo "使用 VS Code CLI: ${CODE_CMD}"
echo "========================================================"

EXTENSIONS=(
    # --- Python & Jupyter 互動式運算套件 ---
    "ms-toolsai.jupyter"                  # Jupyter 核心引擎
    "ms-toolsai.jupyter-keymap"           # Jupyter 原生快捷鍵習慣
    "ms-toolsai.jupyter-renderers"        # 互動式圖表渲染器
    "ms-python.python"                    # Python 語法高亮與環境識別
    "ms-python.debugpy"                   # Python 斷點除錯器

    # --- AI 程式碼輔助套件 ---
    "anthropic.claude-code"               # Claude Code
    "openai.chatgpt"                      # ChatGPT 官方外掛
    "saoudrizwan.claude-dev"              # Cline (前稱 Claude Dev)
    "rooveterinaryinc.roo-cline"          # Roo Code (多模型 AI 助理)
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
