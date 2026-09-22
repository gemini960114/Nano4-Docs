#!/bin/bash
# ==============================================================================
# check_slurm_env.sh: 檢查 Nano4 (晶創26) Slurm 佇列狀態與錢包 (wallet) 計畫餘額
# ==============================================================================
set -euo pipefail

echo "================================================================================"
echo "💳 1. 計畫錢包 (wallet) 可用計畫代號與 SU 點數餘額"
echo "================================================================================"
if command -v wallet &>/dev/null; then
    wallet
elif [ -f /etc/profile.d/wallet_func.sh ]; then
    # shellcheck source=/dev/null
    source /etc/profile.d/wallet_func.sh
    wallet
else
    echo "⚠️ 未找到 wallet 指令，請確認是否在 Nano4 登入節點。"
fi

echo ""
echo "================================================================================"
echo "🖥️ 2. Nano4 登入節點 (25a-lgn*) 可用之主要佇列即時資源 (sinfo)"
echo "================================================================================"
printf "%-14s %-8s %-12s %-16s %-14s %-12s\n" "Partition" "Status" "TimeLimit" "Hardware/Type" "Total RAM/Node" "Idle/Total"
printf "%-14s %-8s %-12s %-16s %-14s %-12s\n" "----------" "------" "---------" "-------------" "--------------" "----------"

# 定義各分區特性說明
declare -A PART_DESC
PART_DESC["dev"]="8x H200 (141GB)"
PART_DESC["8gpus"]="8x H200 (141GB)"
PART_DESC["gb200-dev"]="4x GB200 (Arm)"
PART_DESC["ngstest"]="CPU (10 min)"
PART_DESC["ngs62g"]="CPU (8C/62GB)"
PART_DESC["ngs250g"]="CPU (250GB RAM)"
PART_DESC["ngs6t"]="Fat (6.2TB RAM)"

for p in dev 8gpus gb200-dev ngstest ngs62g ngs250g ngs6t; do
    info=$(sinfo -p "$p" -o "%a %l %m" -h 2>/dev/null | head -n 1 || true)
    if [ -n "$info" ]; then
        avail=$(echo "$info" | awk '{print $1}')
        limit=$(echo "$info" | awk '{print $2}')
        node_mem=$(echo "$info" | awk '{print $3}')
        node_ram_gb=$(awk "BEGIN {printf \"%.0f GB\", $node_mem/1024}")
        desc="${PART_DESC[$p]:-General}"
        
        # 計算 idle 節點與總節點數
        summary=$(sinfo -p "$p" -o "%D %T" -h 2>/dev/null || true)
        total_nodes=$(echo "$summary" | awk '{sum+=$1} END {print (sum==""?0:sum)}')
        idle_nodes=$(echo "$summary" | awk '$2=="idle" {sum+=$1} END {print (sum==""?0:sum)}')
        
        printf "%-14s %-8s %-12s %-16s %-14s %s/%s\n" "$p" "$avail" "$limit" "$desc" "$node_ram_gb" "$idle_nodes" "$total_nodes"
    fi
done

echo ""
echo "💡 Nano4 關鍵提示："
echo "  1. 派送前使用 'sbatch --test-only <script.slurm>' 進行免扣點模擬預檢。"
echo "  2. 在 'ngs62g' 分區務必指定 '#SBATCH --mem=...'(上限 62G)，否則會因 QOS 限制卡住！"
echo "  3. 在 'dev' 分區務必指定至少 1 顆 GPU ('#SBATCH --gres=gpu:1')。"
echo "  4. 計算節點具備外網直連能力 (Direct Internet)，無須啟動 HTTP Proxy。"
echo "================================================================================"
