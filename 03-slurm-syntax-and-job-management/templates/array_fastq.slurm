#!/usr/bin/env bash
#SBATCH --account=GOV115088           # (-A) 本課程計畫
#SBATCH --job-name=array_fastq        # (-J) 作業名稱
#SBATCH --partition=ngs62g            # (-p) 排程分區 (GOV115088 只能用 ngs62g)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --array=1-4                   # 第 04 章有 4 個樣本 → 4 個子任務
#SBATCH --time=00:10:00
#SBATCH --output=%x-%A_%a.out         # %A=主作業ID, %a=子任務序號
#SBATCH --error=%x-%A_%a.err

# ==============================================================================
# array_fastq.slurm - Lab 8 參考解答：每個陣列子任務處理一個 FASTQ 樣本
# 提交方式: sbatch templates/array_fastq.slurm
# ==============================================================================

set -euo pipefail

# 國網官方規範：執行內容第一行清空模組避免污染
module purge

COURSE_DIR="${COURSE_DIR:-${HOME}/Nano4-Docs}"
FASTQ_DIR="${COURSE_DIR}/04-ai-assisted-bio-pipeline/demo_data/fastq_raw"

# 依檔名排序列出樣本，第 N 個子任務處理第 N 個檔案
mapfile -t FASTQ_FILES < <(ls "${FASTQ_DIR}"/*.fastq.gz)
FASTQ="${FASTQ_FILES[$((SLURM_ARRAY_TASK_ID - 1))]}"

# FASTQ 每 4 行代表一條 read
READS=$(( $(gzip -dc "${FASTQ}" | wc -l) / 4 ))

echo "子任務 ${SLURM_ARRAY_TASK_ID} | 節點 $(hostname -s) | 樣本 $(basename "${FASTQ}") | reads = ${READS}"
