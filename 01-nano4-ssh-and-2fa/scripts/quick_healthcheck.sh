#!/bin/bash
# ==============================================================================
# 晶創26 (Nano4) 登入後快速健康檢查腳本
# 用途：確認目前登入節點狀態、計畫點數、WekaFS 儲存空間、軟體環境與外網連通性
# ==============================================================================

set -u

echo "=========================================================="
echo " 🚀 晶創26 (Nano4) 登入節點環境健檢報告 (Login Node Healthcheck)"
echo "=========================================================="

echo -e "\n[1] 節點與系統資訊："
echo "• 當前主機名稱 (Hostname) : $(hostname -f 2>/dev/null || hostname)"
echo "• 登入使用者 (User)        : $(whoami)"
echo "• 作業系統版本 (OS)        : $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"')"
echo "• CPU 核心數 (Cores)       : $(nproc) 核心 ($(lscpu 2>/dev/null | awk -F: '/Model name/{gsub(/^[ \t]+/, "", $2); print $2}' | head -n 1))"
echo "• 系統總記憶體 (Memory)    : $(free -h | awk '/^Mem:/{print $2}')"

if command -v nvidia-smi &>/dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null | head -n 1)
    if [ -n "${GPU_INFO}" ]; then
        echo "• 登入端 GPU 配備 (GPU)    : ${GPU_INFO} (供前處理與除錯)"
    fi
fi

echo -e "\n[2] 計畫與 SU 錢包餘額 (wallet)："
if command -v wallet &>/dev/null; then
    wallet || echo "⚠️ 查無計畫或 wallet 執行異常"
else
    echo "⚠️ 系統未安裝 wallet 指令，請向管理者確認計畫設定。"
fi

echo -e "\n[3] WekaFS 高速儲存空間確認 (/home vs /work)："
if [ -d "$HOME" ]; then
    HOME_AVAIL=$(df -h "$HOME" | awk 'NR==2 {print $4}')
    HOME_TOTAL=$(df -h "$HOME" | awk 'NR==2 {print $2}')
    echo "• 家目錄 (\$HOME)           : $HOME (容量: ${HOME_TOTAL}, 剩餘: ${HOME_AVAIL})"
    echo "  ↳ 適用: 個人原始碼、Git 倉庫、設定檔 (請留意 Inode 額度)"
fi

if [ -d "/work/$USER" ]; then
    WORK_AVAIL=$(df -h "/work/$USER" | awk 'NR==2 {print $4}')
    WORK_TOTAL=$(df -h "/work/$USER" | awk 'NR==2 {print $2}')
    echo "• 高速暫存工作目錄 (/work)  : /work/$USER (容量: ${WORK_TOTAL}, 剩餘: ${WORK_AVAIL})"
    echo "  ↳ 適用: 模型權重、大資料集、uv 虛擬環境 (MST 預設 1.5TB / GOV預設 100GB，無備份)"
else
    echo "⚠️ /work/$USER 目錄尚未建立，建議手動建立：mkdir -p /work/$USER"
fi

if [ -d "/project" ]; then
    echo "• 計畫共用目錄 (/project)   : 已掛載 (依計畫合約申請配置)"
fi

echo -e "\n[4] 核心軟體環境與容器支援："
# 檢查 Lmod / Modules
if command -v module &>/dev/null || command -v ml &>/dev/null; then
    echo "✅ Lmod 環境模組系統正常 (支援 ml avail / ml load)"
else
    echo "⚠️ 未檢測到 module 工具"
fi

# 檢查 Apptainer / Singularity
if command -v apptainer &>/dev/null; then
    echo "✅ Apptainer 容器引擎已就緒: $(apptainer --version)"
elif command -v singularity &>/dev/null; then
    echo "✅ Singularity 容器引擎已就緒: $(singularity --version)"
fi

# 檢查 uv
if command -v uv &>/dev/null; then
    echo "✅ Python uv 極速套件管理器已就緒: $(uv --version)"
elif [ -x "${HOME}/.local/bin/uv" ]; then
    echo "✅ Python uv 存在於 ~/.local/bin/uv: $("${HOME}/.local/bin/uv" --version)"
else
    echo "ℹ️ uv 尚未安裝，可執行 demo_uv.sh 自動安裝"
fi

echo -e "\n[5] Slurm 資源調度系統 (佇列概況)："
if command -v sinfo &>/dev/null; then
    echo "• H200 GPU 佇列   : dev (4h測試), 8gpus/16gpus (48h), 32gpus/64gpus (24h)"
    echo "• GB200 NVL72 佇列: gb200-dev (2h開發除錯), gb200-r1 (24h), gb200-r2 (12h)"
    echo "• NGS CPU 佇列    : ngstest, ngs8g ~ ngs1000g, ngs1500g ~ ngs6t (大記憶體)"
else
    echo "⚠️ 未檢測到 Slurm 指令"
fi

echo -e "\n[6] 登入節點外網連通性測試："
if curl -s -I --connect-timeout 5 https://huggingface.co | grep -q -E "HTTP/.* [23]00"; then
    echo "✅ 外網連線正常 (Hugging Face 連通)"
else
    echo "⚠️ 外網連線逾時，請檢查防火牆或 DNS"
fi

if curl -s -I --connect-timeout 5 https://github.com | grep -q -E "HTTP/.* [23]00"; then
    echo "✅ 外網連線正常 (GitHub 連通)"
else
    echo "⚠️ GitHub 連線逾時"
fi

echo -e "\n=========================================================="
echo "🎉 健檢完成！晶創26 (Nano4) 登入節點運作正常。"
echo "=========================================================="
