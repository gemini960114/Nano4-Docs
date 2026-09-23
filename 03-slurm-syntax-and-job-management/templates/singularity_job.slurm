#!/usr/bin/env bash
#SBATCH --account=GOV115088           # (-A) iService 計費專案代號
#SBATCH --job-name=apptainer_multiqc  # (-J) 作業名稱
#SBATCH --partition=ngs62g            # (-p) 排程分區 (GOV115088 只能用 ngs62g)
#SBATCH --nodes=1                     # (-N) 節點數
#SBATCH --ntasks-per-node=1           # Task 數
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --time=00:30:00               # (-t) 執行時間上限
#SBATCH --output=%x-%j.out            # (-o) 標準輸出
#SBATCH --error=%x-%j.err             # (-e) 標準錯誤

# ==============================================================================
# singularity_job.slurm - 在 Nano4 計算節點用 Apptainer 容器執行 MultiQC
#
# 用容器把第 04 章產生的 FastQC 結果彙整成 MultiQC 報告。整個作業不載入任何
# 模組：MultiQC 與它需要的 Python 環境都裝在容器裡。
#
# 先完成第 04 章（產生 demo_data/fastqc_out/），再提交：
#   sbatch templates/singularity_job.slurm
# ==============================================================================

set -euo pipefail

# 國網官方規範：執行內容第一行清空模組避免污染
module purge

COURSE_DIR="${COURSE_DIR:-${HOME}/Nano4-Docs}"
FASTQC_DIR="${COURSE_DIR}/04-ai-assisted-bio-pipeline/demo_data/fastqc_out"
WORK_DIR="/work/${USER}/apptainer_lab"

# MultiQC 官方 Docker Hub 映像檔（固定版本，不用 latest）
IMAGE_URI="docker://multiqc/multiqc:v1.35"
# 若講師已事先提供映像檔（例如 Docker Hub 下載次數達上限時），可改用：
#   sbatch --export=ALL,MULTIQC_SIF=/path/to/multiqc_1.35.sif templates/singularity_job.slurm
SIF_IMAGE="${MULTIQC_SIF:-${WORK_DIR}/multiqc_1.35.sif}"

# 容器快取放在 /work，避免塞滿 $HOME
export APPTAINER_CACHEDIR="/work/${USER}/.apptainer_cache"
mkdir -p "${WORK_DIR}" "${APPTAINER_CACHEDIR}"

if ! compgen -G "${FASTQC_DIR}/*_fastqc.zip" >/dev/null; then
    echo "ERROR: 找不到 ${FASTQC_DIR}/*_fastqc.zip，請先完成第 04 章的質控流程" >&2
    exit 1
fi

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業流水號   : ${SLURM_JOB_ID}"
echo "=========================================================="

# 1. 主機本身沒有 multiqc（沒有載入任何模組）
echo "[1] 主機上的 multiqc：$(command -v multiqc || echo '找不到（正常，沒有載入模組）')"

# 2. 拉取容器映像檔（只有第一次需要，之後直接使用 .sif 檔）
if [[ ! -f "${SIF_IMAGE}" ]]; then
    echo "[2] 拉取映像檔 ${IMAGE_URI} ..."
    apptainer pull "${SIF_IMAGE}" "${IMAGE_URI}"
else
    echo "[2] 已有映像檔，略過拉取：${SIF_IMAGE}"
fi

# 3. 容器裡有自己的工具與版本
echo "[3] 容器內的 MultiQC：$(apptainer exec "${SIF_IMAGE}" multiqc --version)"

# 4. 在容器內執行 MultiQC；-B 把主機的 /work 與 $HOME 掛進容器
echo "[4] 以容器執行 MultiQC ..."
apptainer exec -B /work,"${HOME}" "${SIF_IMAGE}" \
    multiqc "${FASTQC_DIR}" -o "${WORK_DIR}/multiqc_out" --force

echo "=========================================================="
echo "報告位置        : ${WORK_DIR}/multiqc_out/multiqc_report.html"
echo "作業順利完成時間: $(date)"
echo "效能分析請執行  : seff ${SLURM_JOB_ID}"
echo "=========================================================="
