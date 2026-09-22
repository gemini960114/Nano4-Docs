#!/usr/bin/env bash
# ==============================================================================
# 01_download_on_login_node.sh - [案例 A] 在登入節點事先下載/準備資料
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data/fastq_raw"
mkdir -p "${DATA_DIR}"

echo "========================================================"
echo "📥 [案例 A：離線模式] 在登入節點準備 FASTQ 示範資料..."
echo "儲存目標: ${DATA_DIR}"
echo "========================================================"

# 調用第 5 章的樣本資料或拆分現有 demo.fastq.gz
SOURCE_FASTQ="${HOME}/demo.fastq.gz"
if [ -f "${SOURCE_FASTQ}" ]; then
    echo "==> 從 ${SOURCE_FASTQ} 提取 4 組示範樣本..."
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) | head -n 4000 | gzip > "${DATA_DIR}/sample_01_R1.fastq.gz"
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) | head -n 8000 | tail -n 4000 | gzip > "${DATA_DIR}/sample_02_R1.fastq.gz"
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) | head -n 12000 | tail -n 4000 | gzip > "${DATA_DIR}/sample_03_R1.fastq.gz"
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) | head -n 16000 | tail -n 4000 | gzip > "${DATA_DIR}/sample_04_R1.fastq.gz"
else
    echo "==> 透過外網下載示範資料..."
    SAMPLE_URL="https://data.qiime2.org/2024.5/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz"
    curl -sSL "${SAMPLE_URL}" | head -c 500000 | gzip > "${DATA_DIR}/sample_01_R1.fastq.gz"
    cp "${DATA_DIR}/sample_01_R1.fastq.gz" "${DATA_DIR}/sample_02_R1.fastq.gz"
fi

echo "--------------------------------------------------------"
echo "✅ 資料事前下載完成！清單："
ls -lh "${DATA_DIR}"/*.fastq.gz
echo "👉 接下來請在計算節點提交: sbatch 02_submit_offline_qc.slurm"
echo "========================================================"
