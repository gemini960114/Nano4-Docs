# AI 提示詞範本：請 AI Agent 將互動管線重構為 Slurm 批次作業 (Nano4 專屬)

您可以直接複製以下提示詞，貼給 VS Code 中的 AI 助手（例如 **OpenCode CLI**、**Antigravity CLI** 或 **Claude Code**），讓 AI 自動將本機或登入節點腳本轉化為符合 Nano4 規範的 Slurm 批次作業：

---

### 📋 提示詞內容 (Prompt Template)

```text
你是一位熟悉國網中心 Nano4 (晶創26) 超級電腦 Slurm 排程器與生物資訊分析的專家。
我原本在登入節點有一個執行 FASTQ 質控分析（FastQC + MultiQC）的互動腳本 `run_fastqc_multiqc.sh`。
現在我希望將這套流程改由 Slurm 佇列派送到 Nano4 計算節點（Compute Node）執行。

請幫我編寫兩個版本的 Slurm 批次作業腳本（符合 Nano4 規格，生醫專案使用 #SBATCH --account=YOUR_BIO_PROJECT_ID 與 --partition=ngs62g，並嚴格加上 #SBATCH --mem=16G 避免 QoS 超限）：

【版本一：事前下載 / 離線運算模式】
- 假設資料已在登入節點下載完畢，存放在 /work/${USER}/ 高速共享目錄。
- Slurm 腳本在計算節點上純離線運行，分配 4 個 CPU 核心與 16GB 記憶體，時間上限 30 分鐘。
- 自動處理 FastQC 多核心平行處理與 MultiQC 匯總。
- 日誌輸出需使用 `%x-%j.out` 避免目錄相依性問題。

【版本二：外網直連 / 動態下載模式】
- Nano4 計算節點具備外網直連能力 (Direct Internet Access)，無需設定 HTTP Proxy。
- Slurm 腳本在開頭檢查網路連通性（curl -I https://data.qiime2.org）。
- 在計算節點上即時透過外網下載 FASTQ 資料（或 Hugging Face 模型），接著立即進行 FastQC 與 MultiQC 分析。
- 加入嚴謹的錯誤處理 (set -euo pipefail) 與執行完成日誌。

請提供結構清晰、包含完整註解的 `.slurm` 腳本以及提交指令。
```
