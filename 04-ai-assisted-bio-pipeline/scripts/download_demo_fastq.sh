#!/usr/bin/env bash
# ==============================================================================
# download_demo_fastq.sh - 下載或準備示範用 FASTQ 樣本資料
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SCRIPT_DIR}/../demo_data/fastq_raw"
mkdir -p "${TARGET_DIR}"

echo "========================================================"
echo "📥 正在準備生物資訊示範 FASTQ 資料集..."
echo "儲存路徑: ${TARGET_DIR}"
echo "========================================================"

# 檢查家目錄是否已有現成 demo.fastq.gz 可作為範本加速處理
if [ -f "${HOME}/demo.fastq.gz" ]; then
    echo "==> 偵測到本機已存在 demo.fastq.gz，正在快速拆分為 4 組示範樣本..."
# 取樣生成 4 組不同長度的示範樣本 (使用 || true 避免 head 關閉 pipe 觸發 SIGPIPE)
(gzip -dc "${HOME}/demo.fastq.gz" 2>/dev/null || true) | head -n 4000 | gzip > "${TARGET_DIR}/sample_01_R1.fastq.gz"
(gzip -dc "${HOME}/demo.fastq.gz" 2>/dev/null || true) | head -n 8000 | tail -n 4000 | gzip > "${TARGET_DIR}/sample_02_R1.fastq.gz"
(gzip -dc "${HOME}/demo.fastq.gz" 2>/dev/null || true) | head -n 12000 | tail -n 4000 | gzip > "${TARGET_DIR}/sample_03_R1.fastq.gz"
(gzip -dc "${HOME}/demo.fastq.gz" 2>/dev/null || true) | head -n 16000 | tail -n 4000 | gzip > "${TARGET_DIR}/sample_04_R1.fastq.gz"
else
    echo "==> 透過網路下載 QIIME 2 Moving Pictures 示範資料..."
    SAMPLE_URL="https://data.qiime2.org/2024.5/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz"
    curl -sSL "${SAMPLE_URL}" -o "${TARGET_DIR}/moving_pictures_demo.fastq.gz"
    # 分割示範
    zcat "${TARGET_DIR}/moving_pictures_demo.fastq.gz" | head -n 4000 | gzip > "${TARGET_DIR}/sample_01_R1.fastq.gz"
    zcat "${TARGET_DIR}/moving_pictures_demo.fastq.gz" | head -n 8000 | tail -n 4000 | gzip > "${TARGET_DIR}/sample_02_R1.fastq.gz"
    rm -f "${TARGET_DIR}/moving_pictures_demo.fastq.gz"
fi

echo "--------------------------------------------------------"
echo "✅ 示範 FASTQ 檔案準備完成！清單如下："
ls -lh "${TARGET_DIR}"/*.fastq.gz
echo "========================================================"
