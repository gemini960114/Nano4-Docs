#!/usr/bin/env bash
# ==============================================================================
# download_demo_fastq.sh - 下載或準備示範用 FASTQ 樣本資料
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SCRIPT_DIR}/../demo_data/fastq_raw"
SAMPLE_URL="https://data.qiime2.org/2024.5/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz"
READS_PER_SAMPLE=1000
mkdir -p "${TARGET_DIR}"

echo "========================================================"
echo "📥 正在準備生物資訊示範 FASTQ 資料集..."
echo "儲存路徑: ${TARGET_DIR}"
echo "========================================================"

# repository 已附 4 組示範樣本；已存在時直接沿用，避免改動 Git 追蹤的檔案。
# 如需重新下載，執行：FORCE_DOWNLOAD=1 bash download_demo_fastq.sh
if [ "${FORCE_DOWNLOAD:-0}" != "1" ] && ls "${TARGET_DIR}"/sample_0{1,2,3,4}_R1.fastq.gz &>/dev/null; then
    echo "✅ 已存在 4 組示範樣本，直接沿用："
    ls -lh "${TARGET_DIR}"/*.fastq.gz
    exit 0
fi

# 優先使用家目錄現成的 demo.fastq.gz；否則下載 QIIME 2 Moving Pictures 示範資料
SOURCE_FASTQ="${HOME}/demo.fastq.gz"
DOWNLOADED=""
if [ -f "${SOURCE_FASTQ}" ]; then
    echo "==> 偵測到 ${SOURCE_FASTQ}，直接拆分為 4 組示範樣本..."
else
    echo "==> 透過網路下載 QIIME 2 Moving Pictures 示範資料..."
    SOURCE_FASTQ="${TARGET_DIR}/moving_pictures_demo.fastq.gz"
    DOWNLOADED="${SOURCE_FASTQ}"
    curl -fsSL --retry 3 "${SAMPLE_URL}" -o "${SOURCE_FASTQ}"
fi

# 每組樣本取連續 1000 條 reads (每條 4 行)。
# 以 (gzip -dc ... || true) 包住，避免 head 提早關閉 pipe 時 pipefail 讓腳本中止。
lines=$((READS_PER_SAMPLE * 4))
for i in 1 2 3 4; do
    (gzip -dc "${SOURCE_FASTQ}" 2>/dev/null || true) \
        | head -n $((lines * i)) | tail -n "${lines}" \
        | gzip > "${TARGET_DIR}/sample_0${i}_R1.fastq.gz"
done

if [ -n "${DOWNLOADED}" ]; then
    rm -f "${DOWNLOADED}"
fi

echo "--------------------------------------------------------"
echo "✅ 示範 FASTQ 檔案準備完成！清單如下："
ls -lh "${TARGET_DIR}"/*.fastq.gz
echo "========================================================"
