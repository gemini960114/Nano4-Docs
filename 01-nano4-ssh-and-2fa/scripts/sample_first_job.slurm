#!/bin/bash
# ==============================================================================
# 晶創26 (Nano4) 初學者第一個 Slurm 批次作業範本 (My First Job)
# 用途：示範完整的 Slurm Directives、環境清理、模組載入與任務執行
# ==============================================================================

# 1. Slurm 指揮宣告 (Directives)
#SBATCH --account=YOUR_PROJECT_ID          # (-A) 請替換為您的 iService 計畫代碼 (如 GOV113021 或 MST109178)
#SBATCH --job-name=first_hpc_job           # (-J) 作業自訂名稱
#SBATCH --partition=dev                    # (-p) 佇列：GPU 測試選 dev；若為純 CPU 生醫計算可改為 ngstest
#SBATCH --nodes=1                          # (-N) 申請節點數量
#SBATCH --cpus-per-task=4                  # 每個任務分配的 CPU 核心數
#SBATCH --gres=gpu:1                       # 申請 GPU 數量 (⚠️ 若使用 ngstest 等純 CPU 佇列請註解此行)
#SBATCH --time=00:10:00                    # 最長執行時間 (時:分:秒)
#SBATCH --output=%x-%j.out                 # 標準輸出記錄檔 (%x=Job名, %j=JobID)
#SBATCH --error=%x-%j.err                  # 錯誤訊息記錄檔

# 2. 國網第一鐵律：清空登入端殘留環境
module purge

# 3. 載入所需模組 (依任務需求載入)
module load gcc/11.5
module load cuda/12.6

# 4. 印出執行節點環境資訊 (有助於除錯與記錄)
echo "=========================================================="
echo "🎉 恭喜！您的第一個 Slurm 作業已在計算節點成功啟動！"
echo "• 執行節點主機名稱    : $(hostname)"
echo "• 獲得的 Slurm Job ID : ${SLURM_JOB_ID:-N/A}"
echo "• 分配到的 CPU 核心數 : ${SLURM_CPUS_PER_TASK:-1}"
echo "• 當前工作目錄        : $(pwd)"
echo "• 開始執行時間        : $(date)"
echo "=========================================================="

# 5. 若有申請 GPU，檢查指派的 GPU 狀態
if command -v nvidia-smi &>/dev/null; then
    echo -e "\n[GPU 狀態資訊]"
    nvidia-smi --query-gpu=index,name,memory.total,utilization.gpu --format=csv
fi

# 6. 模擬執行一段運算任務 (可替換為 python script 或自訂分析)
echo -e "\n[開始執行模擬計算任務...]"
sleep 5
echo "計算完成！產出結果檔案..."
echo "Hello Nano4 HPC from job ${SLURM_JOB_ID:-test} on $(hostname)" > "result_${SLURM_JOB_ID:-test}.txt"

echo -e "\n=========================================================="
echo "✅ 作業執行圓滿完成！結束時間: $(date)"
echo "💡 提示：作業結束後，可在登入節點執行：seff ${SLURM_JOB_ID:-<JOB_ID>} 查詢運算效率！"
echo "=========================================================="
