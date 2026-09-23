#!/bin/bash
# ==============================================================================
# validate_slurm.sh: 驗證 Nano4 (晶創26) Slurm 腳本之參數合理性與模擬排程預檢
# ==============================================================================
set -euo pipefail

SLURM_FILE="${1:-}"
if [ -z "$SLURM_FILE" ] || [ ! -f "$SLURM_FILE" ]; then
    echo "❌ 錯誤：請指定有效的 Slurm 腳本路徑。"
    echo "用法：$0 <your_job.slurm>"
    exit 1
fi

ERRORS=0

echo "================================================================================"
echo "🔍 正在針對 Nano4 叢集規範靜態分析 Slurm 腳本：$SLURM_FILE"
echo "================================================================================"

# 1. 檢查 Account
ACCOUNT=$(grep -E "^#SBATCH\s+(-A|--account=)" "$SLURM_FILE" | head -n 1 | awk -F'=' '{print $2}' | awk '{print $1}' | tr -d ' ' || true)
if [ -z "$ACCOUNT" ]; then
    ACCOUNT=$(grep -E "^#SBATCH\s+-A\s+" "$SLURM_FILE" | head -n 1 | awk '{print $3}' || true)
fi

if [ -z "$ACCOUNT" ]; then
    echo "❌ [嚴重錯誤] 缺少計費計畫代號 (#SBATCH -A 或 #SBATCH --account)！"
    ERRORS=$((ERRORS + 1))
    echo "   Nano4 Slurm 必須明確指定計畫代號，否則排程器會直接拒絕派送。"
else
    echo "✅ 計畫代號 (Account): $ACCOUNT"
fi

# 2. 檢查 Partition
PARTITION=$(grep -E "^#SBATCH\s+(-p|--partition=)" "$SLURM_FILE" | head -n 1 | awk -F'=' '{print $2}' | awk '{print $1}' | tr -d ' ' || true)
if [ -z "$PARTITION" ]; then
    PARTITION=$(grep -E "^#SBATCH\s+-p\s+" "$SLURM_FILE" | head -n 1 | awk '{print $3}' || true)
fi

if [ -z "$PARTITION" ]; then
    echo "⚠️ [警告] 未指定佇列分區 (#SBATCH -p / --partition)。"
else
    echo "✅ 佇列分區 (Partition): $PARTITION"

    # 本課程計畫 GOV115088 在 NGS CPU 佇列中只能使用 ngs62g
    if [ "$ACCOUNT" == "GOV115088" ] && [ "$PARTITION" != "ngs62g" ]; then
        echo "❌ [授權錯誤] 計畫 GOV115088 只能使用 ngs62g，'$PARTITION' 會被排程器拒絕！"
        ERRORS=$((ERRORS + 1))
    fi
    
    # 檢查是否為 F1 舊分區
    if [[ "$PARTITION" =~ ^(ct112|cf112|hm112|visual-dev|visual|vscode|jupyter|arm144)$ ]]; then
        echo "❌ [嚴重錯誤] 分區 '$PARTITION' 為舊創進一號 (F1) 佇列，Nano4 叢集不存在此分區！"
        ERRORS=$((ERRORS + 1))
        echo "   建議替換："
        echo "   - CPU 生醫運算 ➔ ngs62g (GOV115088 唯一可用)；MST109178 另可用 ngstest, ngs250g"
        echo "   - GPU 運算 ➔ dev (H200 最長 4h), 8gpus"
        echo "   - Arm 運算 ➔ gb200-dev (GB200 最長 2h)"
    fi
fi

# 3. 檢查核心數與節點數
NODES=$(grep -E "^#SBATCH\s+(-N|--nodes=)" "$SLURM_FILE" | head -n 1 | awk -F'=' '{print $2}' | awk '{print $1}' || echo "1")
CPUS=$(grep -E "^#SBATCH\s+(-c|--cpus-per-task=)" "$SLURM_FILE" | head -n 1 | awk -F'=' '{print $2}' | awk '{print $1}' || echo "1")
echo "✅ 申請資源規模: 節點數 = $NODES, 每個行程核心數 = $CPUS"

# 4. 檢查 ngs62g 官方規格 (國網規定固定搭配：-c 8 --mem=62G)
if [ "$PARTITION" == "ngs62g" ]; then
    if [ "$CPUS" != "8" ]; then
        echo "❌ [規格錯誤] 'ngs62g' 官方規格為 -c 8，目前設定為 $CPUS 核心！"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ ngs62g 核心數符合官方規格: -c 8"
    fi

    MEM_VALUE=$(grep -E "^#SBATCH\s+--mem=" "$SLURM_FILE" | head -n 1 | sed -E 's/^#SBATCH\s+--mem=([^ ]+).*/\1/' || true)
    if [ -z "$MEM_VALUE" ]; then
        echo "❌ [致命地雷] 'ngs62g' 必須明確指定 #SBATCH --mem=62G！"
        ERRORS=$((ERRORS + 1))
        echo "   未指定時 Slurm 預設申請整台節點 1024GB 記憶體，會直接被 QoS 拒絕 (QOSMaxMemoryPerJob)！"
    elif [[ ! "$MEM_VALUE" =~ ^62[Gg]$ ]]; then
        echo "❌ [規格錯誤] 'ngs62g' 官方規格為 --mem=62G，目前設定為 $MEM_VALUE！"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ ngs62g 記憶體符合官方規格: --mem=62G"
    fi
fi

# 5. 檢查 dev GPU 分區特殊規則 (必須指定 --gres=gpu:1)
if [[ "$PARTITION" =~ ^(dev|8gpus)$ ]]; then
    GRES_GPU=$(grep -E "^#SBATCH\s+--gres=gpu:" "$SLURM_FILE" | head -n 1 || true)
    if [ -z "$GRES_GPU" ]; then
        echo "❌ [QoS 錯誤] GPU 分區 '$PARTITION' 必須指定至少 1 顆 GPU (#SBATCH --gres=gpu:1)！"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ GPU 資源請求: $GRES_GPU"
    fi
fi

# 6. 檢查日誌目錄依賴
LOG_OUT=$(grep -E "^#SBATCH\s+(-o|--output=)" "$SLURM_FILE" | head -n 1 | awk -F'=' '{print $2}' | awk '{print $1}' || true)
if [[ "$LOG_OUT" == */* ]]; then
    DIR_PART=$(dirname "$LOG_OUT")
    if [ ! -d "$DIR_PART" ]; then
        echo "❌ [地雷警告] 日誌路徑 '$LOG_OUT' 的目錄 '$DIR_PART' 不存在！"
        ERRORS=$((ERRORS + 1))
        echo "   Slurm 不會自動建立目錄，作業將立即崩潰 (No such file or directory)。"
        echo "   建議改用萬用格式: #SBATCH --output=%x-%j.out"
    fi
fi

echo ""
echo "================================================================================"
echo "🚀 7. 執行排程器免扣點預檢 (sbatch --test-only)"
echo "================================================================================"
TEST_OUTPUT=$(sbatch --test-only "$SLURM_FILE" 2>&1 || true)

SCHEDULER_OK=0
if echo "$TEST_OUTPUT" | grep -qi "Job [0-9]* to start"; then
    SCHEDULER_OK=1
    echo "✅ 排程器接受帳號與分區組合："
    echo "$TEST_OUTPUT"
elif echo "$TEST_OUTPUT" | grep -qi "error\|violate\|invalid\|denied"; then
    echo "❌ 排程器拒絕接受此作業，原因如下："
    echo "$TEST_OUTPUT"
else
    echo "預檢輸出："
    echo "$TEST_OUTPUT"
fi
echo "================================================================================"

# sbatch --test-only 不檢查 QoS 與官方規格，因此靜態檢查的錯誤一樣會判定失敗
if [ "$ERRORS" -gt 0 ] || [ "$SCHEDULER_OK" -ne 1 ]; then
    REASONS=()
    [ "$ERRORS" -gt 0 ] && REASONS+=("靜態檢查發現 ${ERRORS} 個錯誤")
    [ "$SCHEDULER_OK" -ne 1 ] && REASONS+=("排程器預檢未通過")
    echo "❌ [驗證失敗] $(IFS='、'; echo "${REASONS[*]}")。請修正上方標示 ❌ 的項目後再驗證，不要提交此腳本。"
    echo "================================================================================"
    exit 1
fi

echo "🎉 [驗證通過] 靜態檢查與排程器預檢皆通過！"
echo "💡 您隨時可以使用以下指令正式提交作業："
echo "   sbatch $SLURM_FILE"
echo "================================================================================"
