#!/bin/bash
# ==============================================================================
# Slurm 批次排程範本：Nano4 大記憶體 / 基因組組裝運算 (Fat Node High-Memory)
# 適用於：SPAdes, Trinity, 龐大矩陣運算, 大規模 De novo 基因組組裝
# ==============================================================================
#SBATCH --account=GOV115088                  # 必填：wallet 查詢之可用計畫代號 (生醫: GOV115088)
#SBATCH --job-name=fat_task                  # 作業識別名稱
#SBATCH --partition=ngs250g                  # 大記憶體佇列 (可依需求調整為 ngs500g, ngs1000g, 或高達 6.2TB 的 ngs6t)
#SBATCH --nodes=1                            # 單節點運算
#SBATCH --ntasks-per-node=1                  # 節點內主行程數
#SBATCH --cpus-per-task=32                   # 分配 CPU 核心數
#SBATCH --mem=250G                           # 【關鍵】指定大記憶體配額
#SBATCH --time=24:00:00                      # 作業最長時限 (D-HH:MM:SS)
#SBATCH --output=%x-%j.out                   # 標準輸出 (%x:作業名, %j:作業ID)
#SBATCH --error=%x-%j.err                    # 標準錯誤

set -euo pipefail

echo "================================================================================"
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業任務 ID  : ${SLURM_JOB_ID}"
echo "分配 CPU 核心: ${SLURM_CPUS_PER_TASK}"
echo "工作目錄     : $(pwd)"
echo "================================================================================"

module purge 2>/dev/null || true

# 執行高記憶體消耗任務
# spades.py -t "${SLURM_CPUS_PER_TASK}" -m 240 ...

echo "================================================================================"
echo "作業完成時間 : $(date)"
echo "效能分析請執行: seff ${SLURM_JOB_ID}"
echo "================================================================================"
