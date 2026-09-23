#!/bin/bash
# ==============================================================================
# Slurm 管線範本：Nano4 外網直連 / 動態下載模式 (Case B: Direct Internet Online)
# 適用於：計算節點具備 Direct Internet 能力，動態下載模型/數據並進行即時運算
# ==============================================================================
#SBATCH --account=GOV115088                  # 必填：有效計畫代號 (生醫: GOV115088)
#SBATCH --job-name=online_pipeline           # 作業名稱
#SBATCH --partition=ngs62g                   # 佇列分區 (Nano4 生醫佇列)
#SBATCH --nodes=1                            # 節點數
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8                    # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                            # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --time=01:00:00                      # 時限
#SBATCH --output=%x-%j.out                   # 輸出日誌
#SBATCH --error=%x-%j.err                    # 錯誤日誌

set -euo pipefail

# 國網官方規範：執行內容第一行清空模組避免污染，再依需求載入對應環境
module purge

echo "================================================================================"
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業任務 ID  : ${SLURM_JOB_ID}"
echo "分配 CPU 核心: ${SLURM_CPUS_PER_TASK}"
echo "工作目錄     : $(pwd)"
echo "================================================================================"

module purge 2>/dev/null || true

# 1. 測試 Nano4 計算節點外網直連能力 (無須任何 Proxy)
echo "正在測試外網直連連線..."
if curl -s -I --connect-timeout 5 https://github.com >/dev/null; then
    echo "✅ 外網連通正常！(Nano4 計算節點具備原生外網連線能力)"
fi

# 2. 動態拉取資料或模型 (範例)
echo "正在動態下載遠端資料集..."
# curl -sSL https://example.com/dataset.tar.gz -o /work/${USER}/dataset.tar.gz

# 3. 執行分析運算 (多核心平行處理)
echo "正在執行核心分析管線..."
# python3 process.py --threads "${SLURM_CPUS_PER_TASK}"

echo "================================================================================"
echo "作業完成時間 : $(date)"
echo "效能分析請執行: seff ${SLURM_JOB_ID}"
echo "================================================================================"
