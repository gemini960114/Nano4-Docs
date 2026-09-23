#!/bin/bash
#SBATCH --account=GOV115088           # 本課程計畫
#SBATCH --job-name=day1_qc            # 作業名稱
#SBATCH --partition=ngs62g            # GOV115088 唯一可用的 NGS CPU 佇列
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：8 核心
#SBATCH --mem=62G                     # ngs62g 官方規格：62 GB
#SBATCH --time=00:15:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# ==============================================================================
# day1_fastqc_multiqc.slurm - 第一堂結尾示範：手動送出 FastQC + MultiQC 質控作業
# 用法：cd /work/$USER && sbatch "$HOME/Nano4-Docs/02-vscode-and-ai-tools/templates/day1_fastqc_multiqc.slurm"
# 資料：教材附的 4 個 FASTQ（各 1000 reads）；結果寫到 /work/$USER/day1_qc
# ==============================================================================

module purge
module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC   # 計算節點沒有系統 Java
set -euo pipefail

FASTQ_DIR="${FASTQ_DIR:-${HOME}/Nano4-Docs/04-ai-assisted-bio-pipeline/demo_data/fastq_raw}"
OUT_DIR="/work/${USER}/day1_qc"
mkdir -p "${OUT_DIR}/fastqc_out" "${OUT_DIR}/multiqc_out"

echo "節點：$(hostname -s)｜核心：${SLURM_CPUS_PER_TASK}｜作業：${SLURM_JOB_ID}"

fastqc -t "${SLURM_CPUS_PER_TASK}" -o "${OUT_DIR}/fastqc_out" "${FASTQ_DIR}"/*.fastq.gz

# FastQC 找不到 Java 時仍會回傳 0，因此以產出的報告數量確認是否成功
n_in=$(ls "${FASTQ_DIR}"/*.fastq.gz | wc -l)
n_out=$(ls "${OUT_DIR}"/fastqc_out/*_fastqc.zip 2>/dev/null | wc -l)
if [ "${n_out}" -lt "${n_in}" ]; then
    echo "❌ FastQC 只產出 ${n_out}/${n_in} 份報告，請檢查 .err 日誌" >&2
    exit 1
fi

multiqc "${OUT_DIR}/fastqc_out" -o "${OUT_DIR}/multiqc_out" --force

echo "✅ 完成！MultiQC 報告：${OUT_DIR}/multiqc_out/multiqc_report.html"
