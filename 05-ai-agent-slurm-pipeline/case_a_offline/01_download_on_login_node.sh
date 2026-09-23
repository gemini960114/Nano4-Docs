#!/usr/bin/env bash
# ==============================================================================
# 01_download_on_login_node.sh - [案例 A] 在登入節點事先下載/準備資料
# ==============================================================================
set -euo pipefail

DATA_ROOT="${DATA_ROOT:-/work/${USER}/nano4-case-a-qc}"
DATA_DIR="${DATA_ROOT}/fastq_raw"
SAMPLE_URL="https://data.qiime2.org/2024.5/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz"
READS_PER_SAMPLE=1000
mkdir -p "${DATA_DIR}"

echo "========================================================"
echo "📥 [案例 A：離線模式] 在登入節點準備 FASTQ 示範資料..."
echo "儲存目標: ${DATA_DIR}"
echo "========================================================"

# 優先使用家目錄現成的 demo.fastq.gz；否則先完整下載到 /work，再拆分樣本
SOURCE_FASTQ="${HOME}/demo.fastq.gz"
DOWNLOADED=""
if [ -f "${SOURCE_FASTQ}" ]; then
    echo "==> 從 ${SOURCE_FASTQ} 提取 4 組示範樣本..."
else
    echo "==> 透過外網下載 QIIME 2 Moving Pictures 示範資料..."
    SOURCE_FASTQ="${DATA_ROOT}/moving_pictures_demo.fastq.gz"
    DOWNLOADED="${SOURCE_FASTQ}"
    curl -fsSL --retry 3 "${SAMPLE_URL}" -o "${SOURCE_FASTQ}"
fi

# 每組樣本取連續 1000 條 reads；(gzip -dc ... || true) 避免 head 關閉 pipe 時 pipefail 中止腳本
lines=$((READS_PER_SAMPLE * 4))
for i in 1 2 3 4; do
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) \
        | head -n $((lines * i)) | tail -n "${lines}" \
        | gzip > "${DATA_DIR}/sample_0${i}_R1.fastq.gz"
done

if [ -n "${DOWNLOADED}" ]; then
    rm -f "${DOWNLOADED}"
fi

echo "--------------------------------------------------------"
echo "✅ 資料事前下載完成！清單："
ls -lh "${DATA_DIR}"/*.fastq.gz
echo "👉 接下來請提交計算節點作業: sbatch --account=GOV115088 02_submit_offline_qc.slurm"
echo "========================================================"
