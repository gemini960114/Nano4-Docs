#!/usr/bin/env bash
#SBATCH --account=GOV115088           # (-A) iService 計費專案代號 (本課程: GOV115088)
#SBATCH --job-name=cpu_job            # (-J) 作業名稱
#SBATCH --partition=ngs62g            # (-p) 排程分區 (GOV115088 只能用 ngs62g)
#SBATCH --nodes=1                     # (-N) 分配節點數
#SBATCH --ntasks-per-node=1           # 每個節點執行的 Task 數
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --time=00:30:00               # (-t) 最長運行時間 (時:分:秒 或 日-時:分:秒)
#SBATCH --output=%x-%j.out            # (-o) 標準輸出日誌 (%x=作業名稱, %j=作業ID)
#SBATCH --error=%x-%j.err             # (-e) 標準錯誤日誌
#SBATCH --mail-type=END,FAIL          # 郵件通知觸發時機 (BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=your_email@example.com

# ==============================================================================
# standard_cpu_job.slurm - Nano4 標準 CPU 批次作業範本
# 提交方式: sbatch standard_cpu_job.slurm
# 覆寫計畫代號範例: sbatch --account=GOV115088 standard_cpu_job.slurm
# ==============================================================================

set -euo pipefail

# 1. 國網官方規範：執行內容第一行清空模組避免污染，再依需求載入對應環境
module purge

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行節點主機 : $(hostname -s)"
echo "Slurm 作業ID : ${SLURM_JOB_ID}"
echo "分配 CPU 核心: ${SLURM_CPUS_PER_TASK}"
echo "分配記憶體   : ${SLURM_MEM_PER_NODE:-'未指定'} MB"
echo "工作目錄     : $(pwd)"
echo "=========================================================="

# 2. 執行您的核心程式或運算 (例如 Python 運算)
echo "==> 開始執行任務..."
# python3 my_script.py --threads "${SLURM_CPUS_PER_TASK}"

sleep 5

echo "=========================================================="
echo "作業順利完成時間: $(date)"
echo "效能分析請執行  : seff ${SLURM_JOB_ID}"
echo "=========================================================="
