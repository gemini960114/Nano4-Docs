#!/bin/bash
#SBATCH --account=GOV115088           # 本課程計畫代號 (國網生技醫藥高效能運算推廣與應用計畫)；其他計畫請以 wallet 查詢結果替換
#SBATCH --job-name=qc_offline         # 作業名稱
#SBATCH --partition=ngs62g            # 排程分區 (GOV115088 唯一可用的 NGS CPU 佇列)
#SBATCH --nodes=1                     # 節點數
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --ntasks-per-node=1           # Task 數
#SBATCH --time=00:30:00               # 執行時間上限
#SBATCH --output=%x-%j.out            # 標準輸出日誌
#SBATCH --error=%x-%j.err             # 標準錯誤日誌

# ==============================================================================
# 02_submit_offline_qc.slurm - [案例 A] 計算節點離線執行 FastQC 與 MultiQC (Nano4 版)
# 提交指令: sbatch 02_submit_offline_qc.slurm
# 覆寫專案代號: sbatch --account=<PROJECT_ID> 02_submit_offline_qc.slurm
# ==============================================================================

set -euo pipefail

# 0. 【國網規範】重設環境模組，再載入官方 Java、FastQC 與 MultiQC 模組 (計算節點沒有系統 Java)
module purge
module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業任務 ID  : ${SLURM_JOB_ID}"
echo "模式         : 案例 A (事前下載 / 純離線分析)"
echo "=========================================================="

DATA_ROOT="${DATA_ROOT:-/work/${USER}/nano4-case-a-qc}"
DATA_DIR="${DATA_ROOT}/fastq_raw"
FASTQC_OUT="${DATA_ROOT}/fastqc_out_offline"
MULTIQC_OUT="${DATA_ROOT}/multiqc_out_offline"

mkdir -p "${FASTQC_OUT}" "${MULTIQC_OUT}"

# 1. 檢查事前下載的資料是否存在
if [ ! -d "${DATA_DIR}" ] || [ -z "$(ls -A "${DATA_DIR}"/*.fastq.gz 2>/dev/null || true)" ]; then
    echo "❌ 錯誤: 找不到原始資料！請先在登入節點執行 01_download_on_login_node.sh！"
    exit 1
fi

# 2. 執行 FastQC (使用 Slurm 分配的核心數)
echo "==> [步驟 1/2] 執行 FastQC 質控 (使用 ${SLURM_CPUS_PER_TASK} 核心)..."
fastqc -t "${SLURM_CPUS_PER_TASK}" "${DATA_DIR}"/*.fastq.gz -o "${FASTQC_OUT}"

# FastQC 找不到 Java 時仍會回傳 0，因此以實際產出的報告數量確認是否成功
n_in=$(ls "${DATA_DIR}"/*.fastq.gz | wc -l)
n_out=$(ls "${FASTQC_OUT}"/*_fastqc.zip 2>/dev/null | wc -l)
if [ "${n_out}" -lt "${n_in}" ]; then
    echo "❌ FastQC 只產出 ${n_out}/${n_in} 份報告，請檢查 .err 日誌（常見原因：未載入 biology/JDK）。" >&2
    exit 1
fi

# 3. 執行 MultiQC 彙整
echo "==> [步驟 2/2] 執行 MultiQC 報告匯整..."
multiqc "${FASTQC_OUT}" -o "${MULTIQC_OUT}" --force

echo "=========================================================="
echo "✅ 案例 A 離線質控完成！"
echo "MultiQC 報告: ${MULTIQC_OUT}/multiqc_report.html"
echo "完成時間    : $(date)"
echo "效能分析    : seff ${SLURM_JOB_ID}"
echo "=========================================================="
