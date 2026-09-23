#!/usr/bin/env bash
# ==============================================================================
# interactive_salloc.sh - 一鍵啟動 Nano4 計算節點互動式除錯終端 (salloc + srun --pty)
#
# 使用方式:
#   1. 生醫 CPU 測試 (預設):
#      ./interactive_salloc.sh GOV115088 ngs62g 8 00:30:00 62G   # ngs62g 官方規格：-c 8 --mem=62G
#   2. 一般 AI H200 GPU 測試:
#      ./interactive_salloc.sh GOV113021 dev 12 01:00:00 64G 1
# ==============================================================================
set -euo pipefail

ACCOUNT="${1:-GOV115088}"
PARTITION="${2:-ngs62g}"
CPUS="${3:-8}"
TIME_LIMIT="${4:-00:30:00}"
MEM="${5:-62G}"
GPUS="${6:-0}"

echo "========================================================"
echo "🚀 正在向 Nano4 Slurm 申請互動式計算節點資源..."
echo "計畫代號 (Account)  : ${ACCOUNT}"
echo "申請佇列 (Partition): ${PARTITION}"
echo "分配核心 (CPUs)     : ${CPUS}"
echo "記憶體配額 (Mem)    : ${MEM}"
echo "GPU 數量 (GPUs)     : ${GPUS}"
echo "時間上限 (Walltime) : ${TIME_LIMIT}"
echo "========================================================"
echo "提示: 進入節點終端後，測試完畢請輸入 exit 退出以停止計費。"
echo "--------------------------------------------------------"

# 依是否有要求 GPU 加入 --gres 參數
EXTRA_ARGS=()
if [ "${GPUS}" -gt 0 ]; then
    EXTRA_ARGS+=(--gres="gpu:${GPUS}")
fi

salloc \
  --account="${ACCOUNT}" \
  --partition="${PARTITION}" \
  --nodes=1 \
  --cpus-per-task="${CPUS}" \
  --mem="${MEM}" \
  --time="${TIME_LIMIT}" \
  "${EXTRA_ARGS[@]}" \
  srun --pty /bin/bash
