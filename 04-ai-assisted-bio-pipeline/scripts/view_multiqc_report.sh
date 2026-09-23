#!/usr/bin/env bash
# ==============================================================================
# view_multiqc_report.sh - 透過 VS Code Remote-SSH 埠號轉送或本機瀏覽器預覽 MultiQC 報告
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 可指定報告所在資料夾，例如 bash view_multiqc_report.sh /work/$USER/slurm_lab/qc/multiqc_out
REPORT_DIR="${1:-${SCRIPT_DIR}/../demo_data/multiqc_out}"
REPORT_FILE="${REPORT_DIR}/multiqc_report.html"

if [ ! -f "${REPORT_FILE}" ]; then
    echo "❌ 找不到 ${REPORT_FILE}，請先執行 run_fastqc_multiqc.sh 產生報告！"
    exit 1
fi

PORT=$(python3 -c "import socket; s=socket.socket(); s.bind(('',0)); print(s.getsockname()[1]); s.close()")
SESSION="svc-multiqc-report"

if tmux has-session -t "${SESSION}" 2>/dev/null; then
    tmux kill-session -t "${SESSION}"
fi

# 啟動 Python HTTP 伺服器提供 HTML 預覽 (綁定 127.0.0.1 確保安全)
tmux new-session -d -s "${SESSION}" "cd '${REPORT_DIR}' && python3 -m http.server ${PORT} --bind 127.0.0.1"

echo "========================================================"
echo "📊 MultiQC HTML 報告預覽服務已啟動！"
echo "========================================================"
echo "主機節點 : $(hostname -s)"
echo "分配埠號 : ${PORT}"
echo "--------------------------------------------------------"
echo "👉 檢視報告方式 (VS Code Remote-SSH 使用者推薦)："
echo "   1. VS Code 終端機通常會跳出提示：「在瀏覽器中開啟通訊埠 ${PORT}」"
echo "   2. 若無提示，請切換至 VS Code 下方面板「連接埠 (Ports)」頁籤"
echo "      點擊「轉送通訊埠 (Forward a Port)」並輸入 ${PORT}"
echo "   3. 在筆電瀏覽器打開：http://localhost:${PORT}/multiqc_report.html"
echo "--------------------------------------------------------"
echo "💡 方式二 (直接下載)：在 VS Code 左側檔案總管找到 multiqc_report.html，"
echo "   按右鍵選擇「下載... (Download...)」直接用筆電瀏覽器打開！"
echo "--------------------------------------------------------"
echo "關閉預覽服務指令: tmux kill-session -t ${SESSION}"
echo "========================================================"
