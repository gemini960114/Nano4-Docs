# AI 提示詞範本：請 AI Agent 將互動管線重構為 Slurm 批次作業 (Nano4 專屬)

您可以直接複製以下提示詞，貼給 VS Code 中的 AI 助手（例如 **OpenCode CLI**、**Antigravity CLI** 或 **Claude Code**），讓 AI 自動將本機腳本轉化為高可靠度的 Slurm 批次作業：

---

### 📋 提示詞內容 (Prompt Template)

```text
你是一位熟悉國網中心 Nano4 (晶創26) 超級電腦 Slurm 排程器與生物資訊分析的專家。
我原本在登入節點有一個執行 FASTQ 質控分析（FastQC + MultiQC）的互動腳本 `run_fastqc_multiqc.sh`。
現在我希望將這套流程改由 Slurm 佇列派送到計算節點（Compute Node）執行。

請幫我編寫兩個版本的 Slurm 批次作業腳本（符合國網中心 Nano4 規格，生醫專案使用 #SBATCH --account=GOV115088 與 --partition=ngs62g，並依 ngs62g 官方規格加上 #SBATCH --cpus-per-task=8 與 #SBATCH --mem=62G）：

【版本一：事前下載 / 離線運算模式】
- 假設資料已在登入節點下載完畢，存放在 /work/${USER}/ 高速共享目錄。
- Slurm 腳本在計算節點上純離線運行，依 ngs62g 官方規格分配 8 個 CPU 核心與 62GB 記憶體，時間上限 30 分鐘。
- 自動處理 FastQC 多核心平行處理與 MultiQC 匯總。
- 腳本開頭先 `module purge`，再 `module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC`（計算節點沒有系統 Java）。
- 日誌輸出需使用 `%x-%j.out` 避免目錄相依性問題。

【版本二：外網直連 / 動態下載模式】
- Nano4 計算節點具備外網直連能力 (Direct Internet Access)，無需設定 HTTP Proxy。
- Slurm 腳本在開頭用 `curl -fsSIL` 檢查「實際要下載的 FASTQ 網址」是否可連線（例如 https://data.qiime2.org/ 上的檔案；只測網站首頁可能回 404）。
- 在計算節點上即時透過外網下載 FASTQ 資料（或 Hugging Face 模型），接著立即進行 FastQC 與 MultiQC 分析。
- 同樣在腳本開頭先 `module purge`，再 `module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC`，日誌使用 `%x-%j.out` / `%x-%j.err`。
- 加入嚴謹的錯誤處理 (set -euo pipefail) 與執行完成日誌。

請提供結構清晰、包含完整註解的 `.slurm` 腳本以及提交指令。
```
