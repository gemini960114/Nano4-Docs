#!/bin/bash
#SBATCH --account=GOV115088           # 本課程計畫代號 (國網生技醫藥高效能運算推廣與應用計畫)；其他計畫請以 wallet 查詢結果替換
#SBATCH --job-name=qc_online          # 作業名稱
#SBATCH --partition=ngs62g            # 排程分區 (GOV115088 唯一可用的 NGS CPU 佇列)
#SBATCH --nodes=1                     # 節點數
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --ntasks-per-node=1           # Task 數
#SBATCH --time=00:30:00               # 執行時間上限
#SBATCH --output=%x-%j.out            # 標準輸出日誌
#SBATCH --error=%x-%j.err             # 標準錯誤日誌

# ==============================================================================
# run_online_pipeline.slurm - [案例 B] Nano4 計算節點外網直連動態下載與分析
# 提交指令: sbatch run_online_pipeline.slurm
# 特性說明: Nano4 計算節點預設具備直連網際網路能力，無需啟動登入節點 Proxy！
# ==============================================================================

set -euo pipefail

# 0. 【國網規範】重設環境模組，再載入官方 Java、FastQC 與 MultiQC 模組 (計算節點沒有系統 Java)
module purge
module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業任務 ID  : ${SLURM_JOB_ID}"
echo "模式         : 案例 B (Nano4 計算節點外網直連 / 動態下載與質控)"
echo "=========================================================="

DATA_ROOT="${DATA_ROOT:-/work/${USER}/nano4-case-b-qc}"
DATA_DIR="${DATA_ROOT}/fastq_dynamic"
FASTQC_OUT="${DATA_ROOT}/fastqc_out_online"
MULTIQC_OUT="${DATA_ROOT}/multiqc_out_online"
SAMPLE_URL="https://data.qiime2.org/2024.5/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz"
READS_PER_SAMPLE=1000

mkdir -p "${DATA_DIR}" "${FASTQC_OUT}" "${MULTIQC_OUT}"

# 1. 【Nano4 特色】驗證計算節點對外網路連通性 (無須 Proxy 隧道，節點自帶外網)
echo "==> [步驟 1/3] 測試 Nano4 計算節點外網直連連線..."
if curl -fsSIL --connect-timeout 10 -o /dev/null "${SAMPLE_URL}"; then
    echo "✅ 外網直連成功！(Nano4 計算節點具備 Direct Internet 存取能力)"
else
    echo "❌ 計算節點無法連線至 data.qiime2.org，請確認網路狀態後重新提交。" >&2
    exit 1
fi

# 2. 在計算節點上即時下載資料，完整下載後再拆分為 2 組示範樣本
echo "==> [步驟 2/3] 在計算節點上動態下載 FASTQ 資料..."
SOURCE_FASTQ="${DATA_DIR}/moving_pictures_demo.fastq.gz"
curl -fsSL --retry 3 "${SAMPLE_URL}" -o "${SOURCE_FASTQ}"
lines=$((READS_PER_SAMPLE * 4))
for i in 1 2; do
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) \
        | head -n $((lines * i)) | tail -n "${lines}" \
        | gzip > "${DATA_DIR}/dynamic_sample_0${i}.fastq.gz"
done
rm -f "${SOURCE_FASTQ}"
echo "動態下載完成，檔案清單："
ls -lh "${DATA_DIR}"/*.fastq.gz

# 3. 執行 FastQC 與 MultiQC 質控
echo "==> [步驟 3/3] 執行 FastQC 與 MultiQC..."
fastqc -t "${SLURM_CPUS_PER_TASK}" "${DATA_DIR}"/*.fastq.gz -o "${FASTQC_OUT}"

# FastQC 找不到 Java 時仍會回傳 0，因此以實際產出的報告數量確認是否成功
n_in=$(ls "${DATA_DIR}"/*.fastq.gz | wc -l)
n_out=$(ls "${FASTQC_OUT}"/*_fastqc.zip 2>/dev/null | wc -l)
if [ "${n_out}" -lt "${n_in}" ]; then
    echo "❌ FastQC 只產出 ${n_out}/${n_in} 份報告，請檢查 .err 日誌（常見原因：未載入 biology/JDK）。" >&2
    exit 1
fi
multiqc "${FASTQC_OUT}" -o "${MULTIQC_OUT}" --force

echo "=========================================================="
echo "✅ 案例 B 動態下載質控完成！"
echo "MultiQC 報告: ${MULTIQC_OUT}/multiqc_report.html"
echo "完成時間    : $(date)"
echo "效能分析    : seff ${SLURM_JOB_ID}"
echo "=========================================================="
