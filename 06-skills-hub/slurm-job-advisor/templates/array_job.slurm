#!/bin/bash
# ==============================================================================
# Slurm 批次排程範本：Nano4 批次多樣本平行陣列作業 (Job Array)
# 適用於：批次處理數十至數百個 FASTQ 樣本之質控、比對
# ==============================================================================
#SBATCH --account=GOV115088                  # 必填：wallet 查詢之可用計畫代號 (生醫: GOV115088)
#SBATCH --job-name=array_qc                  # 作業識別名稱
#SBATCH --partition=ngs62g                   # 排程分區 (Nano4 生醫佇列)
#SBATCH --nodes=1                            # 每個子任務申請 1 節點
#SBATCH --cpus-per-task=2                    # 每個子任務分配核心數
#SBATCH --mem=8G                             # 每個子任務分配記憶體
#SBATCH --array=1-10%4                       # 【關鍵】10 個子任務，最多同時執行 4 個
#SBATCH --time=01:00:00                      # 每個子任務時間上限
#SBATCH --output=%x-%A_%a.out                # 【關鍵】%A:主作業ID, %a:陣列子任務序號
#SBATCH --error=%x-%A_%a.err

set -euo pipefail

echo "================================================================================"
echo "主作業 ID   : ${SLURM_ARRAY_JOB_ID}"
echo "子任務序號  : ${SLURM_ARRAY_TASK_ID}"
echo "執行計算節點: $(hostname -s)"
echo "啟動時間    : $(date)"
echo "================================================================================"

module purge 2>/dev/null || true

# 範例：根據 SLURM_ARRAY_TASK_ID 讀取樣本清單中的第 N 行
# SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" sample_list.txt)
# echo "正在處理樣本: ${SAMPLE}"

echo "子任務 ${SLURM_ARRAY_TASK_ID} 處理完畢！"
