#!/usr/bin/env bash
#SBATCH --account=GOV113021           # (-A) iService 計費專案代號 (一般 AI 專案)
#SBATCH --job-name=gpu_h200_job       # (-J) 作業名稱
#SBATCH --partition=dev               # (-p) Nano4 H200 測試分區 (dev 最長 4 小時)
#SBATCH --nodes=1                     # (-N) 分配節點數
#SBATCH --ntasks-per-node=1           # 每個節點執行的 Task 數
#SBATCH --cpus-per-task=12            # (-c) CPU 核心數 (每 GPU 建議配 12 核心)
#SBATCH --mem=64G                     # 申請記憶體
#SBATCH --gres=gpu:1                  # 【關鍵】申請 1 顆 NVIDIA H200 141GB GPU
#SBATCH --time=01:00:00               # 最長運行時間
#SBATCH --output=%x-%j.out            # 標準輸出日誌
#SBATCH --error=%x-%j.err             # 標準錯誤日誌

# ==============================================================================
# gpu_job.slurm - Nano4 NVIDIA H200 GPU 運算作業範本
# 提交方式: sbatch gpu_job.slurm
# 覆寫專案代號: sbatch --account=GOV113021 gpu_job.slurm
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo "作業啟動時間 : $(date)"
echo "執行節點主機 : $(hostname -s)"
echo "Slurm 作業ID : ${SLURM_JOB_ID}"
echo "分配 GPU 資源: ${CUDA_VISIBLE_DEVICES:-'未指定'}"
echo "=========================================================="

# 1. 國網官方規範：第一行清空模組
module purge

# 2. 檢查 NVIDIA H200 GPU 狀態
if command -v nvidia-smi &>/dev/null; then
    nvidia-smi
fi

# 3. 執行 GPU 訓練或推論任務
echo "==> 開始執行深度學習任務..."
# python3 -c "import torch; print('CUDA 是否可用:', torch.cuda.is_available()); print('GPU 名稱:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else '無')"

echo "=========================================================="
echo "GPU 作業完成時間: $(date)"
echo "效能分析請執行  : seff ${SLURM_JOB_ID}"
echo "=========================================================="
