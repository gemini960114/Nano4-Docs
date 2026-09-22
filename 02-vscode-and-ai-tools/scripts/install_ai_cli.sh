#!/usr/bin/env bash
# ==============================================================================
# install_ai_cli.sh - 安裝與配置 Antigravity CLI (agy) 與 OpenCode CLI
# ==============================================================================
set -euo pipefail

echo "========================================================"
echo "🤖 開始配置 AI 命令行開發工具 (agy & opencode)..."
echo "========================================================"

# 1. 確保使用者本機 bin 目錄存在
mkdir -p "${HOME}/.local/bin"
mkdir -p "${HOME}/.opencode/bin"

# 2. 檢查 / 安裝 OpenCode CLI
echo "==> [1/2] 檢查 OpenCode CLI..."
if command -v opencode &>/dev/null; then
    echo "✅ OpenCode 已安裝: $(opencode --version)"
elif [ -x "${HOME}/.opencode/bin/opencode" ]; then
    echo "✅ 偵測到 ${HOME}/.opencode/bin/opencode"
else
    echo "正在下載並安裝 OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
fi

# 3. 檢查 Antigravity CLI (agy)
echo "==> [2/2] 檢查 Antigravity CLI (agy)..."
if command -v agy &>/dev/null; then
    echo "✅ agy 已存在於系統 PATH: $(which agy)"
elif [ -x "${HOME}/.local/bin/agy" ]; then
    echo "✅ 偵測到 ${HOME}/.local/bin/agy"
else
    echo "ℹ️ 請確認 agy 二進位檔已放置於 ~/.local/bin/agy。"
fi

# 4. 確保環境變數 PATH 包含 ~/.local/bin 與 ~/.opencode/bin
BASHRC="${HOME}/.bashrc"
EXPORT_STR='export PATH="${HOME}/.local/bin:${HOME}/.opencode/bin:${PATH}"'

if ! grep -q ".opencode/bin" "${BASHRC}" 2>/dev/null; then
    echo "==> 正在將路徑加入 ${BASHRC}..."
    echo "" >> "${BASHRC}"
    echo "# AI CLI tools (agy & opencode)" >> "${BASHRC}"
    echo "${EXPORT_STR}" >> "${BASHRC}"
    echo "✅ 已寫入 PATH 至 ~/.bashrc！"
else
    echo "ℹ️ ~/.bashrc 已包含相關路徑設定。"
fi

echo "========================================================"
echo "🎉 AI CLI 工具配置完成！"
echo "請執行: source ~/.bashrc 讓環境變數立即生效。"
echo "========================================================"
