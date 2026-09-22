#!/usr/bin/env bash
#SBATCH --account=GOV115088           # (-A) 計費專案代號 (例如生醫專案 GOV115088)
#SBATCH --job-name=array_job          # (-J) 作業名稱
#SBATCH --partition=ngs62g            # (-p) 排程分區 (例如 ngs62g)
#SBATCH --nodes=1                     # 每個陣列任務使用 1 節點
#SBATCH --cpus-per-task=2             # 每個任務分配 2 核心
#SBATCH --mem=4G                      # 【關鍵】每個陣列任務分配 4GB 記憶體
#SBATCH --array=1-10%4                # 【關鍵】陣列範圍 1 到 10，%4 代表最多同時跑 4 個任務
#SBATCH --time=00:30:00               # 每個任務時間上限
#SBATCH --output=%x-%A_%a.out         # 【關鍵】%A=主作業ID, %a=陣列子任務序號 (1~10)
#SBATCH --error=%x-%A_%a.err          # 錯誤日誌

# ==============================================================================
# array_job.slurm - Nano4 Slurm 陣列作業範本 (多樣本批次平行處理必備)
# 提交方式: sbatch array_job.slurm
# 覆寫專案代號: sbatch --account=GOV115088 array_job.slurm
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo "主作業 ID (Master Job ID) : ${SLURM_ARRAY_JOB_ID}"
echo "目前子任務序號 (Task Index): ${SLURM_ARRAY_TASK_ID}"
echo "執行節點                  : $(hostname -s)"
echo "啟動時間                  : $(date)"
echo "=========================================================="

# 範例：根據 SLURM_ARRAY_TASK_ID 讀取樣本清單中的第 N 行進行處理
# SAMPLE_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" sample_list.txt)
# echo "正在處理樣本: ${SAMPLE_NAME}"

echo "處理子任務 ${SLURM_ARRAY_TASK_ID} 執行中..."
sleep 5

echo "處理子任務 ${SLURM_ARRAY_TASK_ID} 完成！"
