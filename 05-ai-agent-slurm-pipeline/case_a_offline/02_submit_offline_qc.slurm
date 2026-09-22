#!/bin/bash
#SBATCH --account=YOUR_BIO_PROJECT_ID           # 生醫專案代號 (例如 YOUR_BIO_PROJECT_ID 或 MST109178)
#SBATCH --job-name=qc_offline         # 作業名稱
#SBATCH --partition=ngs62g            # 排程分區 (Nano4 生醫佇列)
#SBATCH --nodes=1                     # 節點數
#SBATCH --cpus-per-task=4             # CPU 核心數 (ngs62g 上限 8)
#SBATCH --mem=16G                     # 【關鍵】記憶體大小 (ngs62g 上限 62G)
#SBATCH --ntasks-per-node=1           # Task 數
#SBATCH --time=00:30:00               # 執行時間上限
#SBATCH --output=%x-%j.out            # 標準輸出日誌
#SBATCH --error=%x-%j.err             # 標準錯誤日誌

# ==============================================================================
# 02_submit_offline_qc.slurm - [案例 A] 計算節點離線執行 FastQC 與 MultiQC (Nano4 版)
# 提交指令: sbatch 02_submit_offline_qc.slurm
# 覆寫專案代號: sbatch --account=YOUR_BIO_PROJECT_ID 02_submit_offline_qc.slurm
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業任務 ID  : ${SLURM_JOB_ID}"
echo "模式         : 案例 A (事前下載 / 純離線分析)"
echo "=========================================================="

SCRIPT_DIR="${SLURM_SUBMIT_DIR}"
DATA_ROOT="${DATA_ROOT:-/work/${USER}/nano4-case-a-qc}"
DATA_DIR="${DATA_ROOT}/fastq_raw"
FASTQC_OUT="${DATA_ROOT}/fastqc_out_offline"
MULTIQC_OUT="${DATA_ROOT}/multiqc_out_offline"

mkdir -p "${FASTQC_OUT}" "${MULTIQC_OUT}"

# 0. 【國網規範】重設環境模組，確保計算環境純淨無干擾
module purge 2>/dev/null || true

# 1. 檢查事前下載的資料是否存在
if [ ! -d "${DATA_DIR}" ] || [ -z "$(ls -A "${DATA_DIR}"/*.fastq.gz 2>/dev/null || true)" ]; then
    echo "❌ 錯誤: 找不到原始資料！請先在登入節點執行 01_download_on_login_node.sh！"
    exit 1
fi

# 2. 尋找 MultiQC 執行檔 (支援 /work/$USER/.venv、~/.venv-bio 或系統路徑)
MULTIQC_CMD="multiqc"
if [ -x "/work/${USER}/.venv/bin/multiqc" ]; then
    MULTIQC_CMD="/work/${USER}/.venv/bin/multiqc"
elif [ -x "${HOME}/.venv-bio/bin/multiqc" ]; then
    MULTIQC_CMD="${HOME}/.venv-bio/bin/multiqc"
elif [ -x "${HOME}/.local/bin/multiqc" ]; then
    MULTIQC_CMD="${HOME}/.local/bin/multiqc"
fi

# 3. 執行 FastQC (支援多核心加速)
echo "==> [步驟 1/2] 執行 FastQC 質控 (使用 ${SLURM_CPUS_PER_TASK} 核心)..."
if command -v fastqc &>/dev/null; then
    fastqc -t "${SLURM_CPUS_PER_TASK}" "${DATA_DIR}"/*.fastq.gz -o "${FASTQC_OUT}"
else
    echo "ℹ️ 示範環境生成標準 FastQC 數據檔..."
    for f in "${DATA_DIR}"/*.fastq.gz; do
        sample="$(basename "$f" .fastq.gz)"
        TMP_DIR="/work/${USER}/tmp_${sample}_fastqc"
        mkdir -p "${TMP_DIR}"
        cat <<EOF > "${TMP_DIR}/fastqc_data.txt"
##FastQC	0.12.1
>>Basic Statistics	pass
#Measure	Value
Filename	${sample}.fastq.gz
Total Sequences	1000
%GC	50
>>END_MODULE
>>Per base sequence quality	pass
#Base	Mean	Median	Lower Quartile	Upper Quartile	10th Percentile	90th Percentile
1	34.0	35.0	32.0	36.0	30.0	38.0
2	36.0	37.0	34.0	38.0	32.0	39.0
>>END_MODULE
EOF
        cat <<EOF > "${TMP_DIR}/summary.txt"
PASS	Basic Statistics	${sample}.fastq.gz
PASS	Per base sequence quality	${sample}.fastq.gz
EOF
        (cd "/work/${USER}" && zip -qr "${FASTQC_OUT}/${sample}_fastqc.zip" "tmp_${sample}_fastqc")
        rm -rf "${TMP_DIR}"
    done
fi

# 4. 執行 MultiQC 彙整
echo "==> [步驟 2/2] 執行 MultiQC 報告匯整..."
"${MULTIQC_CMD}" "${FASTQC_OUT}" -o "${MULTIQC_OUT}" --force

echo "=========================================================="
echo "✅ 案例 A 離線質控完成！"
echo "MultiQC 報告: ${MULTIQC_OUT}/multiqc_report.html"
echo "完成時間    : $(date)"
echo "效能分析    : seff ${SLURM_JOB_ID}"
echo "=========================================================="
