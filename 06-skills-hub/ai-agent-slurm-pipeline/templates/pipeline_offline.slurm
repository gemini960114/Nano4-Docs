#!/bin/bash
# ==============================================================================
# Slurm 管線範本：Nano4 純離線運算模式 (Case A: Pre-staged Offline Execution)
# 適用於：資料/模型已預先存放於 /work 儲存區，計算節點純離線高速運算
# ==============================================================================
#SBATCH --account=GOV115088                  # 必填：有效計畫代號 (生醫: GOV115088)
#SBATCH --job-name=offline_pipeline          # 作業名稱
#SBATCH --partition=ngs62g                   # 佇列分區 (Nano4 生醫佇列)
#SBATCH --nodes=1                            # 節點數
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4                    # 核心數
#SBATCH --mem=16G                            # 【關鍵】記憶體配額 (ngs62g 上限 62G)
#SBATCH --time=01:00:00                      # 時限
#SBATCH --output=%x-%j.out                   # 輸出日誌
#SBATCH --error=%x-%j.err                    # 錯誤日誌

set -euo pipefail

echo "================================================================================"
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業任務 ID  : ${SLURM_JOB_ID}"
echo "分配 CPU 核心: ${SLURM_CPUS_PER_TASK}"
echo "工作目錄     : $(pwd)"
echo "================================================================================"

module purge 2>/dev/null || true

# 檢查輸入檔案是否存在 (Nano4 高速磁區為 /work)
INPUT_DIR="/work/${USER}/data"
if [ ! -d "$INPUT_DIR" ]; then
    echo "⚠️ 找不到資料目錄 $INPUT_DIR，請先完成資料準備。"
fi

# 執行分析運算 (多核心平行處理)
echo "正在執行核心分析管線..."
# python3 analyze.py --threads "${SLURM_CPUS_PER_TASK}"

echo "================================================================================"
echo "作業完成時間 : $(date)"
echo "效能分析請執行: seff ${SLURM_JOB_ID}"
echo "================================================================================"
