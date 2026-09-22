#!/bin/bash
# ==============================================================================
# 晶創26 (Nano4) 初學者純 CPU 批次作業範本 (CPU Job on ngs62g)
# 用途：示範生醫專屬計畫 (如 GOV115088 / MST109178) 在 ngs62g CPU 佇列上的標準提交設定
# ==============================================================================

# 1. Slurm 指揮宣告 (Directives)
#SBATCH --account=GOV115088          # (-A) 生醫計費專案代號 (請依 wallet 查詢結果填寫)
#SBATCH --job-name=first_cpu_job     # (-J) 作業自訂名稱
#SBATCH --partition=ngs62g           # (-p) Nano4 生醫專屬 CPU 佇列 (ngs62g)
#SBATCH --nodes=1                    # (-N) 申請 1 台計算節點
#SBATCH --ntasks-per-node=1          # 每個節點執行的任務數
#SBATCH --cpus-per-task=4            # 每個任務分配的 CPU 核心數 (ngs62g 建議 1~8 核心)
#SBATCH --mem=16G                    # ⚠️【關鍵必填】記憶體配額 (ngs62g 上限 62G，漏填會觸發 QOSMaxMemoryPerJob 卡死)
#SBATCH --time=00:15:00              # 最長執行時間 (時:分:秒)
#SBATCH --output=%x-%j.out           # 標準輸出日誌 (%x=作業名稱, %j=作業序號)
#SBATCH --error=%x-%j.err            # 標準錯誤日誌
# (⚠️ 純 CPU 佇列嚴禁加上 --gres=gpu:1，否則排程器會拒絕派送)

# 2. 國網第一鐵律：清空登入端殘留環境
module purge

# 3. 載入所需模組 (依任務需求載入，純 CPU 任務通常載入 GCC 或 Bio 工具)
module load gcc/11.5

# 4. 印出執行節點環境資訊 (有助於除錯與記錄)
echo "=========================================================="
echo "🎉 恭喜！您的純 CPU Slurm 作業已在 ngs62g 計算節點成功啟動！"
echo "• 執行節點主機名稱    : $(hostname)"
echo "• 獲得的 Slurm Job ID : ${SLURM_JOB_ID:-N/A}"
echo "• 運算分區 (Partition): ${SLURM_JOB_PARTITION:-ngs62g}"
echo "• 分配到的 CPU 核心數 : ${SLURM_CPUS_PER_TASK:-1}"
echo "• 申請的記憶體大小    : ${SLURM_MEM_PER_NODE:-16384} MB"
echo "• 當前工作目錄        : $(pwd)"
echo "• 開始執行時間        : $(date)"
echo "=========================================================="

# 5. 執行一段純 CPU 計算任務 (例如使用 Python 或 Bash 進行多核心處理)
echo -e "\n[開始執行 CPU 運算任務...]"
python3 -c "
import sys, time
print(f'Python 運行於: {sys.executable}')
print('正在進行 CPU 矩陣平行計算模擬...')
time.sleep(3)
print('CPU 計算順利完成！')
"

echo "Hello Nano4 ngs62g CPU node from job ${SLURM_JOB_ID:-test} on $(hostname)" > "result_cpu_${SLURM_JOB_ID:-test}.txt"

echo -e "\n=========================================================="
echo "✅ 作業執行圓滿完成！結束時間: $(date)"
echo "💡 提示：作業結束後，可在登入節點執行：seff ${SLURM_JOB_ID:-<JOB_ID>} 查詢 CPU 與記憶體利用率！"
echo "=========================================================="
