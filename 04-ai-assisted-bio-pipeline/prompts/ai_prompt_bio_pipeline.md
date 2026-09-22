# AI 提示詞範本：請 AI Agent 撰寫 FASTQ 質控分析管線

您可以直接複製以下提示詞（Prompt），貼給 VS Code 中的 AI 助手（例如 **Claude Code**、**Zoo Code** 或 **OpenCode**），讓 AI 助理自動為您生成分析腳本：

---

### 📋 提示詞內容 (Prompt Template)

```text
你是一位熟悉生物資訊分析（Bioinformatics）與 Linux HPC 環境的專業工程師。
我目前在 HPC 登入節點上，需要建立一套 FASTQ 資料前處理與品質控制（Quality Control, QC）管線。

請幫我編寫一個 Bash 腳本 `run_qc_pipeline.sh`，要求包含以下步驟：
1. 自動下載 QIIME 2 Moving Pictures 的示範 FASTQ 資料（或從指定 URL 抓取多個樣本的 .fastq.gz 檔案），存放在 `./fastq_raw/` 目錄中。
2. 檢查系統中是否存在 FastQC 與 MultiQC：
   - 若未安裝 FastQC，請自動下載免編譯的 FastQC zip 檔並解壓縮至使用者目錄。
   - 若未安裝 MultiQC，請透過 pip/uv 進行安裝。
3. 批次對 `./fastq_raw/` 下的所有 FASTQ 檔案執行 FastQC 分析，並將結果輸出至 `./fastqc_out/`。
4. 使用 MultiQC 彙整 `./fastqc_out/` 下的所有分析報告，生成單一的 `./multiqc_out/multiqc_report.html`。
5. 腳本需具備良好的錯誤處理（set -euo pipefail）、清楚的彩色進度提示，並在最後印出報告檔案路徑。

請提供完整、可直接執行的程式碼，並附帶簡易的使用說明。
```
