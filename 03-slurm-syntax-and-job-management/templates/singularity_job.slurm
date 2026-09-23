#!/usr/bin/env bash
#SBATCH --account=GOV115088           # (-A) iService 計費專案代號
#SBATCH --job-name=singularity_job    # (-J) 作業名稱
#SBATCH --partition=ngs62g            # (-p) 排程分區 (或 GPU 任務改用 dev)
#SBATCH --nodes=1                     # (-N) 節點數
#SBATCH --ntasks-per-node=1           # Task 數
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心 (與 --mem=62G 搭配)
#SBATCH --mem=62G                      # ngs62g 官方規格：每個作業 62 GB (與 -c 8 搭配)
#SBATCH --time=00:30:00               # (-t) 執行時間上限
#SBATCH --output=%x-%j.out            # (-o) 標準輸出
#SBATCH --error=%x-%j.err             # (-e) 標準錯誤

# ==============================================================================
# singularity_job.slurm - 在 Nano4 計算節點運行 Singularity 容器作業範本
# 提交指令: sbatch singularity_job.slurm
# ==============================================================================

set -euo pipefail

# 國網官方規範：執行內容第一行清空模組避免污染，再依需求載入對應環境
module purge

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行計算節點 : $(hostname -s)"
echo "作業流水號   : ${SLURM_JOB_ID}"
echo "=========================================================="

# 1. 【國網規範】重設模組環境

# 2. 定義容器映像檔位置與工作目錄 (Nano4 高速工作目錄為 /work/${USER})
WORK_DIR="/work/${USER}"
SIF_IMAGE="${WORK_DIR}/ubuntu_22.04.sif"

# 3. 若容器檔不存在，示範直接從 Docker Hub 拉取 (Nano4 計算節點具備外網直連能力)
if [ ! -f "${SIF_IMAGE}" ]; then
    echo ">> 映像檔不存在，嘗試從 Docker Hub 直接拉取 (Nano4 計算節點具備外網能力)..."
    # singularity pull "${SIF_IMAGE}" docker://ubuntu:22.04
fi

# 4. 在計算節點執行容器 (掛載 /work 目錄，若有 GPU 加上 --nv 參數)
echo "==> 啟動 Singularity 容器執行任務..."
# singularity exec -B "${WORK_DIR}":/mnt "${SIF_IMAGE}" python3 /mnt/script.py

# 示範查看容器系統版本
if command -v singularity &>/dev/null; then
    singularity --version
    echo "✅ Singularity 環境就緒！"
fi

echo "=========================================================="
echo "作業順利完成時間: $(date)"
echo "💡 提示：作業結束後可透過 seff ${SLURM_JOB_ID} 查看資源利用率！"
echo "=========================================================="
