---
name: ai-agent-slurm-pipeline
description: >-
  Comprehensive guide and workflow engine for AI Agents to automatically refactor interactive
  shell/Python scripts into production-ready Slurm batch jobs on HPC clusters (NCHC Nano4 / 晶創26).
  Covers the architectural decision between pure offline execution vs direct-internet compute-node execution,
  automated dependency chaining (`--dependency=afterok:`), multi-step pipeline decomposition,
  strict error handling (`set -euo pipefail`), and pre-flight validation.
---

# AI Agent Slurm Pipeline Refactoring Skill (Nano4 自動化排程管線專家)

本技能指導 AI Agent 如何將使用者在終端機或 VS Code Remote-SSH 內手動執行的**互動式腳本（如生醫質控、資料前處理、機器學習訓練）**，自動重構為符合 Nano4 超級電腦規範的 **高強固性 Slurm 批次排程管線**。

---

## 🎯 核心能力與觸發時機

當使用者提出以下需求時觸發本技能：
1. **管線重構**：「把我在登入節點跑的這段腳本改寫成可以在 Nano4 計算節點跑的 Slurm 排程。」
2. **網路架構抉擇**：「我的程式在計算節點需要下載外部檔案或模型，該怎麼做？」
3. **多階段相依排程**：「我有步驟一（下載）、步驟二（計算）、步驟三（匯總），如何用 Slurm 自動串接？」

---

## 🏗️ 第一部分：Nano4 兩大運算架構決策樹 (Architecture Decision Tree)

在重構腳本前，AI 必須評估該運算是否需要外部網路連線，並引導使用者選擇最佳架構：

```text
               運算任務是否需要連線外網？
                      │
         ┌────────────┴────────────┐
        否                        是
         ▼                         ▼
   【架構 A：純離線運算】       【架構 B：計算節點外網直連】
   - 資料已預先存放於 /work     - Nano4 計算節點具備 Direct Internet
   - 完全不依賴外部連線        - 無需設定 HTTP Proxy 代理
   - 適合大規模、固定資料運算    - 適合需即時下載資料、模型或推播日誌
```

### 1. 架構 A：事前下載 / 高速離線運算模式 (Pre-Staged Offline)
* **核心哲學**：重度計算與外部傳輸徹底解耦。在登入節點完成資料準備，存放於 WekaFS 高速磁區（`/work/${USER}`）；計算節點純離線高速平行運算。
* **優點**：極致穩定，不受外部網站斷線或頻寬波動影響。

### 2. 架構 B：外網直連 / 動態下載模式 (Direct Internet Access)
* **核心哲學**：Nano4 計算節點預設具備 Direct Internet 連網能力。Slurm 腳本可在計算節點直接調用 `curl`、`wget`、`huggingface-cli` 即時拉取最新模型權重或定序數據，並即時將指標回傳至外部服務（如 Weights & Biases、MLflow）。
* **優點**：流程全自動化，無需手動在登入節點預下載。

---

## 🛡️ 第二部分：AI 重構 Slurm 腳本之品質標準 (Quality Checklist)

AI Agent 產生之 Slurm 腳本必須 100% 通過以下安全檢驗：

1. **帳號與分區合規**：
   - 生醫專案：使用有效專案代號（如 `#SBATCH --account=GOV115088`）並派送至 `ngs62g`（或 `ngstest`、`ngs250g`）。
   - 一般 AI 專案：使用一般專案代號（如 `#SBATCH --account=GOV113021`）並派送至 `dev` 或 `8gpus`。
2. **【關鍵防呆】明確指定記憶體**：
   - 在 `ngs62g` 中**務必加上 `#SBATCH --mem=16G`（或最大 62G）**，嚴禁遺漏避免 `QOSMaxMemoryPerJob` 卡死。
   - 在 `dev` 中**務必加上 `#SBATCH --gres=gpu:1`**。
3. **嚴格錯誤攔截**：
   - 腳本頂部加入 `set -euo pipefail`。任一步驟出錯立即終止，避免浪費計畫點數。
4. **無目錄依賴之日誌命名**：
   - 一律採用 `#SBATCH --output=%x-%j.out` 與 `#SBATCH --error=%x-%j.err`。
5. **儲存路徑規範**：
   - 共享資料一律存於 `/work/${USER}`，嚴禁使用 `/work1` 或 `/tmp` 存放持久性大檔。

---

## 🔗 第三部分：自動化相依排程管線 (Pipeline Chaining)

當分析流程包含多個前後相依的步驟時，AI 應指導使用者使用 `--dependency=afterok:<job_id>` 建立全自動化流水線：

```bash
#!/bin/bash
# submit_pipeline.sh: 一鍵送出相依流水線
set -euo pipefail

echo "1. 送出步驟一：資料前處理作業..."
JOB1=$(sbatch --parsable --account=GOV115088 step1_download.slurm)
echo "   ➔ 步驟一 Job ID: $JOB1"

echo "2. 送出步驟二：核心重度計算 (依賴步驟一成功完成)..."
JOB2=$(sbatch --parsable --dependency=afterok:$JOB1 --account=GOV115088 step2_compute.slurm)
echo "   ➔ 步驟二 Job ID: $JOB2"

echo "3. 送出步驟三：報告整合與清理 (依賴步驟二成功完成)..."
JOB3=$(sbatch --parsable --dependency=afterok:$JOB2 --account=GOV115088 step3_report.slurm)
echo "   ➔ 步驟三 Job ID: $JOB3"

echo "✅ 整套流水線作業已全數派送排隊中！"
```
