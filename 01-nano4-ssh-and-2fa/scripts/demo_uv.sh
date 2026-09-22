#!/bin/bash
# ==============================================================================
# 晶創26 (Nano4) 極速 Python 套件管理工具 uv 實務操作示範
# 用途：示範如何使用 uv 在高速工作目錄 (/work) 秒級建立虛擬環境與安裝套件
# ==============================================================================

set -e

echo "=========================================================="
echo " ⚡ 晶創26 (Nano4) Python 套件管理利器：uv 實務示範"
echo "=========================================================="

# 1. 確保 uv 可用 (系統 PATH 或 ~/.local/bin/uv)
UV_BIN="${HOME}/.local/bin/uv"
if command -v uv &>/dev/null; then
    UV_CMD="uv"
elif [ -x "${UV_BIN}" ]; then
    UV_CMD="${UV_BIN}"
else
    echo ">> 安裝 uv 至 ~/.local/bin..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${HOME}/.local/bin:${PATH}"
    UV_CMD="${HOME}/.local/bin/uv"
fi

echo "• uv 版本: $("${UV_CMD}" --version)"

# 2. 設定最佳實踐：將快取目錄指向大容量工作區 (/work) 避免消耗 $HOME 配額
WORK_DIR="/work/${USER}"
if [ ! -d "${WORK_DIR}" ]; then
    WORK_DIR="${HOME}/scratch"
    mkdir -p "${WORK_DIR}"
fi

TARGET_VENV="${WORK_DIR}/test_uv_env"
export UV_CACHE_DIR="${WORK_DIR}/.uv_cache"

echo -e "\n[步驟 1] 在高速工作區 (/work) 建立虛擬環境 (${TARGET_VENV})..."
rm -rf "${TARGET_VENV}"
"${UV_CMD}" venv "${TARGET_VENV}"

echo -e "\n[步驟 2] 透過 uv pip 秒級安裝示範套件 (requests, rich)..."
"${UV_CMD}" pip install --python "${TARGET_VENV}/bin/python" requests rich

echo -e "\n[步驟 3] 驗證虛擬環境運作與 Python 版本..."
"${TARGET_VENV}/bin/python" -c "import platform, requests, rich; print(f'✅ 模組載入成功！系統架構: {platform.machine()}, Requests 版本: {requests.__version__}')"

echo -e "\n=========================================================="
echo "🎉 示範成功！"
echo "💡 提示 1：日常使用時只需執行：source ${TARGET_VENV}/bin/activate 即可啟動環境！"
echo "⚠️ 提示 2 (重要！)：目前登入節點為 x86_64 架構。若您的 Job 需在 GB200 (Arm aarch64) 節點執行，"
echo "           請先透過 srun/salloc 進入 gb200-dev 分區，再於節點上建立專屬的 aarch64 虛擬環境！"
echo "=========================================================="
