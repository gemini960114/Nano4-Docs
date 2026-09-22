#!/bin/bash
# ==============================================================================
# 晶創26 (Nano4) Apptainer / Singularity 容器化技術實務操作示範
# 用途：示範在 HPC 無管理者 (root) 權限下使用容器引擎與快取最佳實踐
# ==============================================================================

set -e

echo "=========================================================="
echo " 🐳 晶創26 (Nano4) Apptainer / Singularity 容器實務示範"
echo "=========================================================="

# 1. 檢測容器命令 (系統原生支援 apptainer 與 singularity 指令)
if command -v apptainer &>/dev/null; then
    CONTAINER_CMD="apptainer"
elif command -v singularity &>/dev/null; then
    CONTAINER_CMD="singularity"
else
    echo ">> 載入 singularity 模組..."
    module load singularity/4.3.7 2>/dev/null || true
    CONTAINER_CMD="singularity"
fi

echo "• 容器引擎指令: ${CONTAINER_CMD}"
echo "• 容器版本資訊: $("${CONTAINER_CMD}" --version)"

# 2. HPC 容器黃金守則：將快取目錄設定在 /work，杜絕灌爆 $HOME 配額！
WORK_DIR="/work/${USER}"
if [ ! -d "${WORK_DIR}" ]; then
    WORK_DIR="${HOME}/scratch"
    mkdir -p "${WORK_DIR}"
fi

export APPTAINER_CACHEDIR="${WORK_DIR}/.apptainer_cache"
export SINGULARITY_CACHEDIR="${WORK_DIR}/.singularity_cache"
mkdir -p "${APPTAINER_CACHEDIR}"

echo -e "\n[步驟 1] 檢查快取與工作目錄配置："
echo "• Apptainer 快取目錄: ${APPTAINER_CACHEDIR}"
echo "• Singularity 快取目錄: ${SINGULARITY_CACHEDIR}"

# 3. 示範容器基本語法說明
echo -e "\n[步驟 2] 常用 HPC 容器執行指令速查："
echo "1. 執行 Docker Hub 上的映像檔 (免事先拉取，自動轉換為 SIF)："
echo "   ${CONTAINER_CMD} exec docker://alpine cat /etc/os-release"
echo ""
echo "2. 啟用 GPU 支援執行 NVIDIA PyTorch 映像檔："
echo "   ${CONTAINER_CMD} exec --nv docker://pytorch/pytorch:latest python -c \"import torch; print('CUDA 可用:', torch.cuda.is_available())\""
echo ""
echo "3. 將遠端 Docker 映像檔拉取並編譯為本地獨立 SIF 檔 (推薦用於 Slurm 批次作業)："
echo "   ${CONTAINER_CMD} build ${WORK_DIR}/my_image.sif docker://ubuntu:22.04"
echo ""
echo "4. 掛載高速工作區 (/work) 進入容器內部："
echo "   ${CONTAINER_CMD} exec --bind /work/${USER}:/workspace ${WORK_DIR}/my_image.sif ls -la /workspace"

echo -e "\n=========================================================="
echo "🎉 示範說明完成！在撰寫 Slurm 排程時可直接結合 ${CONTAINER_CMD} 執行深度學習容器！"
echo "=========================================================="
