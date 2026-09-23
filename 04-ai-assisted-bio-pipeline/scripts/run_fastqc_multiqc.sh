#!/usr/bin/env bash
# ==============================================================================
# run_fastqc_multiqc.sh - 執行 FASTQ 樣本之 FastQC 與 MultiQC 質控流程 (Nano4 版)
# 登入節點微型測試：4 個樣本、各 1000 條 reads，最多使用 4 核心，數秒內完成。
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAW_DIR="${SCRIPT_DIR}/../demo_data/fastq_raw"
FASTQC_OUT="${SCRIPT_DIR}/../demo_data/fastqc_out"
MULTIQC_OUT="${SCRIPT_DIR}/../demo_data/multiqc_out"

mkdir -p "${FASTQC_OUT}" "${MULTIQC_OUT}"

echo "========================================================"
echo "🔬 [1/3] 檢查 FASTQ 原始資料與質控工具..."
echo "========================================================"

if [ ! -d "${RAW_DIR}" ] || [ -z "$(ls -A "${RAW_DIR}"/*.fastq.gz 2>/dev/null || true)" ]; then
    echo "⚠️ 尚未偵測到 FASTQ 檔案，正在呼叫 download_demo_fastq.sh 自動下載/準備..."
    bash "${SCRIPT_DIR}/download_demo_fastq.sh"
fi

# 使用 Nano4 官方 Lmod 模組提供的 Java、FastQC 與 MultiQC
if type module &>/dev/null; then
    module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC
fi
for tool in fastqc multiqc; do
    if ! command -v "${tool}" &>/dev/null; then
        echo "❌ 找不到 ${tool}。請先執行：module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC" >&2
        exit 1
    fi
done
echo "FastQC 執行檔 : $(command -v fastqc)"
echo "MultiQC 執行檔: $(command -v multiqc)"

echo "========================================================"
echo "🧬 [2/3] 執行 FastQC 品質控制分析..."
echo "========================================================"
fastqc -t 4 "${RAW_DIR}"/*.fastq.gz -o "${FASTQC_OUT}"

# FastQC 找不到 Java 時仍會回傳 0，因此以實際產出的報告數量確認是否成功
n_in=$(ls "${RAW_DIR}"/*.fastq.gz | wc -l)
n_out=$(ls "${FASTQC_OUT}"/*_fastqc.zip 2>/dev/null | wc -l)
if [ "${n_out}" -lt "${n_in}" ]; then
    echo "❌ FastQC 只產出 ${n_out}/${n_in} 份報告，請確認已載入 biology/JDK。" >&2
    exit 1
fi

echo "========================================================"
echo "📊 [3/3] 執行 MultiQC 彙整產生單一 HTML 報告..."
echo "========================================================"
multiqc "${FASTQC_OUT}" -o "${MULTIQC_OUT}" --force

echo "--------------------------------------------------------"
echo "🎉 質控管線執行完畢！"
echo "MultiQC 報告位置: ${MULTIQC_OUT}/multiqc_report.html"
echo ""
echo "👉 預覽報告指令 (VS Code 本機瀏覽器轉送預覽):"
echo "   bash ${SCRIPT_DIR}/view_multiqc_report.sh"
echo "========================================================"
